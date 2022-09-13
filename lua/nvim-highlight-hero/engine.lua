local M = {}

-- Get visually selected text
-- URL: https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
local function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function M.autohighlight()
  M.match(1, "123")
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
  vim.b.nvim_highlight_hero = vim.b.nvim_highlight_hero or {
    matches = {},
  }
end

-- Remove match
---@param num number 0-9 for fixed group, -1 for autohighlight
local function match_uninstall(num)
  init_buffer()
  local buffer_config = vim.b.nvim_highlight_hero
  if buffer_config.matches[num] then
    for _, v in ipairs(buffer_config.matches[num]) do
      vim.fn.matchdelete(v)
    end
  end
  buffer_config.matches[num] = nil
  vim.b.nvim_highlight_hero = buffer_config
end


-- Install new match for num and pattern
---comment
---@param num any 0-9 for fixed group, -1 for autohighlight
---@param pattern string regex-pattern to highlight
---@param append boolean append to highlight, if true
local function match_install(num, pattern, append)
  init_buffer()
  if not append then
    match_uninstall(num)
  end
  local id = vim.fn.matchadd(get_highlight_group(num), pattern)
  local buffer_config = vim.b.nvim_highlight_hero
  local id_list= buffer_config.matches[num] or {}
  table.insert(id_list, id)
  buffer_config.matches[num] = id_list
  vim.b.nvim_highlight_hero = buffer_config
end


function M.match(num, append)
  local text
  if vim.api.nvim_get_mode().mode == "n" then
    -- Highlight word under cursor
    text = vim.fn.expand("<cword>")
  elseif vim.api.nvim_get_mode().mode == "v" then
    text = get_visual_selection()
  else
    -- Not supported mode
    return
  end
  local text_regex = string.gsub(text, "\\", "\\\\")
  local pattern = "\\V\\<" .. text_regex .. "\\>"
  match_install(num, pattern, append)
end

function M.match1()
  M.match(1, false)
end

function M.match_append1()
  M.match(1, true)
end

function M.match2()
  M.match(2, false)
end

function M.match_off1()
  match_uninstall(1)
end


return M
