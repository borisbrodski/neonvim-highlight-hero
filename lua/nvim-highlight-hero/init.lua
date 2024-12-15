---@class options
---@field keymaps table<string, boolean|string>
---@field highlight { duration: boolean|integer }

local M = {}

local config = require("nvim-highlight-hero.config")
local engine = require("nvim-highlight-hero.engine")

--- Setup plugin with user configuration.
---@param user_opts table?
function M.setup(user_opts)
	config.setup(user_opts)

	-- Create a user command for toggling autohighlight or other tasks
	vim.api.nvim_create_user_command("HH", M.command_HH, { nargs = "?" })
end

--- Called on CursorMoved to possibly trigger auto-highlighting.
function M.on_cursor_moved()
	if engine.autohighlight_on then
		engine.do_autohighlight()
	end
end

--- User command for `:HH`
--- Examples:
---  :HH            -> Toggle auto-highlight
---  :HH off        -> Turn off all highlights
---  :HH on         -> Turn on auto-highlighting (if off)
function M.command_HH(args)
	local arg = args.args and args.args:lower() or ""

	if arg == "" then
		-- No argument means toggle
		engine.autohighlight()
		print("Auto-highlight toggled. Current state: " .. tostring(engine.autohighlight_on))
		return
	end

	if arg == "off" then
		if engine.autohighlight_on then
			engine.autohighlight()
		end
		-- Additionally, turn off all numbered matches if desired:
		for i = -1, 9 do
			engine.match_off(i)
		end
		return
	end

	local parts = vim.split(arg, "%s+") -- split arguments by space
	local num = tonumber(parts[1])

	if num and num >= 0 and num <= 9 then
		-- If user provided two args and second is 'off'
		if parts[2] == "off" then
			-- Remove all highlights for the given group
			engine.match_off(num)
			print(string.format("Highlight group %d turned OFF and cleared.", num))
			return
		end

		-- Otherwise, we always add a new highlight to the given color <num>
		local mode = vim.api.nvim_get_mode().mode
		if mode == "v" then
			-- In visual mode, highlight the selection, append mode
			engine.match(num, true, false)
			print(string.format("Highlight group %d added (visual selection).", num))
		else
			-- In normal mode, highlight the word under cursor, append mode
			engine.match(num, true)
			print(string.format("Highlight group %d added (current word).", num))
		end
		return
	end

	-- If no recognized numeric argument, let’s guide the user
	print("Usage: :HH <num> to highlight under that group, :HH <num> off to remove that group, :HH off to remove all.")
end

return M
