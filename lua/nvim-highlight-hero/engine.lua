local M = {}

M.autohighlight_on = false

-- Get visually selected text
-- URL: https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
local function get_visual_selection()
  local s_start = vim.fn.getpos("v")
  local s_end = vim.fn.getpos(".")
  print(vim.inspect(s_start) .. " -> " .. vim.inspect(s_end) .. ", " .. tostring(s_start[3] < s_end[3]))
  if s_start[2] > s_end[2] or (s_start[2] == s_end[2] and s_start[3] > s_end[3]) then
    local tmp = s_start
    s_start = s_end
    s_end = tmp
  end
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  -- print(vim.inspect(lines))
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function M.autohighlight()
  print("Current state " .. vim.inspect(M.autohighlight_on))
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
      matches = {}
    }
    init_state.matches[1] = {} -- Autohighlighting
    for buf_num = 0, 9 do      -- Highlight groups
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
  print("Match off " .. buf_num)
  if buffer_config.matches[buf_num + 2] then
    for _, v in ipairs(buffer_config.matches[buf_num + 2]) do
      print("- Removing " .. v)
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
---@param text string to be escaped
---@return string escaped string
local function escape_for_V_regex(text)
  return (string.gsub(text, "\\", "\\\\"))
end

function M.match(num, append, keep_visual)
  local regex_text
  if vim.api.nvim_get_mode().mode == "n" then
    -- Highlight word under cursor
    local text = vim.fn.expand("<cword>")
    regex_text = "\\<" .. escape_for_V_regex(text) .. "\\>"
  elseif vim.api.nvim_get_mode().mode == "v" then
    regex_text = escape_for_V_regex(get_visual_selection())
    if not keep_visual then
      vim.api.nvim_input("<esc>") -- Leave visual mode, TODO: Find a better way
    end
  else
    -- Not supported mode
    return
  end
  local pattern = "\\V" .. regex_text
  match_install(num, pattern, append)
end

return M
