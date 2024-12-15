local M = {}

M.autohighlight_on = false
M.last_pattern = {} -- Store last pattern used per group number (-1 to 9)

local function get_visual_selection()
	local s_start = vim.fn.getpos("v")
	local s_end = vim.fn.getpos(".")

	-- Sort start/end positions so that s_start is always before s_end
	if s_start[2] > s_end[2] or (s_start[2] == s_end[2] and s_start[3] > s_end[3]) then
		s_start, s_end = s_end, s_start
	end

	local start_line, start_col = s_start[2], s_start[3]
	local end_line, end_col = s_end[2], s_end[3]

	local mode = vim.fn.mode()
	if mode == "V" then
		-- Linewise selection: take all lines fully
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		return table.concat(lines, "\n")
	else
		-- Characterwise selection (original logic)
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		local n_lines = #lines

		if n_lines == 0 then
			return ""
		end

		-- Adjust for characterwise selection
		lines[1] = string.sub(lines[1], start_col, #lines[1])
		if n_lines == 1 then
			lines[n_lines] = string.sub(lines[n_lines], 1, end_col - start_col + 1)
		else
			lines[n_lines] = string.sub(lines[n_lines], 1, end_col)
		end

		return table.concat(lines, "\n")
	end
end

function M.autohighlight()
	-- print("Current state " .. vim.inspect(M.autohighlight_on))
	if M.autohighlight_on then
		M.match_off(-1)
	end
	M.autohighlight_on = not M.autohighlight_on
	if M.autohighlight_on then
		M.do_autohighlight()
	end
end

M.i = 1
function M.do_autohighlight()
	if M.autohighlight_on then
		M.match(-1, false, true)
	end
end

-- Return the name of the get_highlight group for the 'num'
---@param num number 0-9 for fixed group, -1 for autohighlight
---@return string name of the group
local function get_highlight_group(num)
	if num >= 0 and num <= 9 then
		return string.format("NvimHighlightHeroMatch%d", num)
	end
	return "NvimHighlightHeroAuto"
end

-- Init current buffer if not initialized already
local function init_buffer()
	if not vim.w.nvim_highlight_hero then
		local init_state = {
			matches = {},
		}
		init_state.matches[1] = {} -- Autohighlighting
		for buf_num = 0, 9 do -- Highlight groups
			init_state.matches[buf_num + 2] = {}
		end
		vim.w.nvim_highlight_hero = init_state
	end
	return vim.w.nvim_highlight_hero
end

-- Remove match
---@param buf_num number 0-9 for fixed group, -1 for autohighlight
function M.match_off(buf_num)
	init_buffer()
	local buffer_config = vim.w.nvim_highlight_hero
	-- print("Match off " .. buf_num)
	if buffer_config.matches[buf_num + 2] then
		for _, v in ipairs(buffer_config.matches[buf_num + 2]) do
			-- print("- Removing " .. v)
			vim.fn.matchdelete(v)
		end
	end
	buffer_config.matches[buf_num + 2] = {}
	vim.w.nvim_highlight_hero = buffer_config
end

-- Install new match for num and pattern
---comment
---@param buf_num any 0-9 for fixed group, -1 for autohighlight
---@param pattern string regex-pattern to highlight
---@param append boolean append to highlight, if true
local function match_install(buf_num, pattern, append)
	init_buffer()
	if not append then
		M.match_off(buf_num)
	end
	local id = vim.fn.matchadd(get_highlight_group(buf_num), pattern)
	local buffer_config = vim.w.nvim_highlight_hero
	local id_list = buffer_config.matches[buf_num + 2]
	table.insert(id_list, id)
	buffer_config.matches[buf_num + 2] = id_list
	vim.w.nvim_highlight_hero = buffer_config
end

---Escape text for usage with \V... regex
--- - Convert all backslashes to `\\`
--- - Split into lines, trim leading and trailing whitespace
--- - Rejoin lines with actual newlines, then convert `\n` to `\\n`
---@param text string to be escaped
---@return string escaped string
local function escape_for_V_regex(text)
	text = text:gsub("\\", "\\\\")

	local lines = {}
	local text_lines = {}

	for line in text:gmatch("[^\n]+") do
		table.insert(text_lines, line)
	end

	if #text_lines < 2 then
		return text
	end

	for _, line in ipairs(text_lines) do
		line = line:gsub("^%s+", ""):gsub("%s+$", "")
		table.insert(lines, "\\s\\*" .. line .. "\\s\\*")
	end

	return table.concat(lines, "\\n")
end

function M.match(num, append, keep_visual)
	local mode = vim.api.nvim_get_mode().mode
	local text
	if mode == "n" then
		text = vim.fn.expand("<cword>")
		if text == "" then
			-- print("No word under cursor to highlight.")
			return
		end
		text = "\\<" .. escape_for_V_regex(text) .. "\\>"
	elseif mode == "v" or mode == "V" then
		local selection = get_visual_selection()
		if selection == "" then
			-- print("No visual selection.")
			return
		end
		text = escape_for_V_regex(selection)
		if not keep_visual then
			vim.api.nvim_input("<esc>")
		end
	else
		return
	end

	local pattern = "\\V" .. text

	-- Check if we're toggling the same pattern for this group (and not appending)
	-- If it's the same pattern and append is false, we turn the group off instead
	if not append and M.last_pattern[num] == pattern then
		M.match_off(num)
		M.last_pattern[num] = nil
		return
	end

	match_install(num, pattern, append)
	M.last_pattern[num] = pattern
end

function M.is_highlight_set(num)
	local buffer_config = init_buffer()
	return #buffer_config.matches[num + 2] > 0
end

return M
