---@class options
---@field keymaps table<string, boolean|string>
---@field highlight { duration: boolean|integer }

local M = {}

local config = require("nvim-highlight-hero.config")

M.setup = config.setup

function M.on_cursor_moved()
end

function M.command_HH()
end

return M

-- TODOs
--
-- Help
-- ====
-- * Describe highlighting configuration. See config.setup()
--
--
-- print(vim.inspect(s_start) .. " --> " .. vim.inspect(s_end))
