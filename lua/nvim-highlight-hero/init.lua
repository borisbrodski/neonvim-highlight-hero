---@class options
---@field keymaps table<string, boolean|string>
---@field highlight { duration: boolean|integer }

local M = {}

local config = require("nvim-highlight-hero.config")

M.setup = config.setup


function M.command_HH()
  local x = vim.fn.matchadd("IncSearch", "234")
end

return M

-- TODOs
--
-- Help
-- ====
-- * Describe highlighting configuration. See config.setup()
