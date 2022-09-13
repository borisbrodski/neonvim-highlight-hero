local M = {}

local default_opts = {
  keymaps = {
    toggle_auto_highlight = "<leader>hh",
    match1                = "<leader>h1",
    match_append1         = "<leader>H1",
    match_off1            = "<leader>ho1",
    match2                = "<leader>h2",
    match_append2         = "<leader>H2",
    match_off2            = "<leader>ho2",
  },
  disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
}

-- Set up user-configured keymaps, globally or for the buffer.
---@param buffer boolean Whether the keymaps should be set for the buffer or not.
function M.set_keymaps(buffer)
  local engine = require("nvim-highlight-hero.engine")
  M.set_keymap({
    name = "Toggle auto-highlight",
    mode = "n",
    lhs = M.get_opts().keymaps.toggle_auto_highlight,
    rhs = engine.autohighlight,
    opts = {
      buffer = buffer,
      desc = "Toggle auto-highlight",
      silent = true,
    },
  })
  M.set_keymap({
    name = "Toggle auto-highlight",
    mode = "v",
    lhs = M.get_opts().keymaps.toggle_auto_highlight,
    rhs = engine.autohighlight,
    opts = {
      buffer = buffer,
      desc = "Toggle auto-highlight",
      silent = true,
    },
  })

  M.set_keymap({
    name = "Highlight match 1",
    mode = "v",
    lhs = M.get_opts().keymaps.match1,
    rhs = engine.match1,
    opts = {
      buffer = buffer,
      desc = "Activate match 1",
      silent = true,
    },
  })
  M.set_keymap({
    name = "Highlight match 1",
    mode = "n",
    lhs = M.get_opts().keymaps.match1,
    rhs = engine.match1,
    opts = {
      buffer = buffer,
      desc = "Activate match 1",
      silent = true,
    },
  })

  M.set_keymap({
    name = "Highlight append match 1",
    mode = "n",
    lhs = M.get_opts().keymaps.match_append1,
    rhs = engine.match_append1,
    opts = {
      buffer = buffer,
      desc = "Highlight append match 1",
      silent = true,
    },
  })
  M.set_keymap({
    name = "Highlight append match 1",
    mode = "v",
    lhs = M.get_opts().keymaps.match_append1,
    rhs = engine.match_append1,
    opts = {
      buffer = buffer,
      desc = "Highlight append match 1",
      silent = true,
    },
  })

  M.set_keymap({
    name = "Highlight match off 1",
    mode = "n",
    lhs = M.get_opts().keymaps.match_append1,
    rhs = engine.match_append1,
    opts = {
      buffer = buffer,
      desc = "Highlight match off 1",
      silent = true,
    },
  })
  M.set_keymap({
    name = "Highlight match off 1",
    mode = "v",
    lhs = M.get_opts().keymaps.match_off1,
    rhs = engine.match_off1,
    opts = {
      buffer = buffer,
      desc = "Highlight match off 1",
      silent = true,
    },
  })
end

-- Check if a keymap should be added before setting it.
---@param args table The arguments to set the keymap.
function M.set_keymap(args)
    -- If the keymap is disabled
    if not args.lhs then
        -- If the mapping is disabled globally, do nothing
        if not M.user_opts.keymaps[args.name] then
            return
        end
        -- Otherwise disable the global keymap
        args.lhs = M.user_opts.keymaps[args.name]
        args.rhs = "<NOP>"
    end
    vim.keymap.set(args.mode, args.lhs, args.rhs, args.opts)
end


-- Returns the buffer-local options for the plugin, or global options if buffer-local does not exist.
---@return options @The buffer-local options.
function M.get_opts()
  return vim.b[0].nvim_highlight_hero_opts or M.user_opts
end


function M.setup(user_opts)
  print("setting up")
  M.user_opts = M.merge_opts(M.translate_opts(default_opts), user_opts)
  M.set_keymaps(false)
  vim.cmd([[
    highlight default link NvimHighlightHeroAuto CursorLineFold
    highlight default link NvimHighlightHeroMatch1 StatusLine
    highlight default link NvimHighlightHeroMatch2 Substitute
    highlight default link NvimHighlightHeroMatch3 CursorColumn
    highlight default link NvimHighlightHeroMatch4 TermCursor
    highlight default link NvimHighlightHeroMatch5 Folded
    highlight default link NvimHighlightHeroMatch6 DiffAdd
    highlight default link NvimHighlightHeroMatch7 DiffDelete
    highlight default link NvimHighlightHeroMatch8 WildMenu
    highlight default link NvimHighlightHeroMatch9 IncSearch
    highlight default link NvimHighlightHeroMatch0 TODO
  ]])
end

-- Setup the user options for the current buffer.
---@param buffer_opts table? The buffer-local options to be merged with the global user_opts.
function M.buffer_setup(buffer_opts)
  vim.b[0].nvim_highlight_hero_opts = M.merge_opts(M.get_opts(), buffer_opts)
  M.set_keymaps(true)
end


-- Updates the buffer-local options for the plugin based on the input.
---@param base_opts options The base options that will be used for configuration.
---@param new_opts options? The new options to potentially override the base options.
---@return options The merged options.
M.merge_opts = function(base_opts, new_opts)
  return new_opts and vim.tbl_deep_extend("force", base_opts, M.translate_opts(new_opts)) or base_opts
end


-- Translates the user-provided configuration into the internal form.
---@param opts options? The user-provided options.
function M.translate_opts(opts)
  -- TODO Add stuff here
  -- -- SOFT DEPRECATION WARNINGS
  -- ---@diagnostic disable-next-line: undefined-field
  -- if opts and opts.highlight_motion then
  --   local highlight_warning = {
  --     "The `highlight_motion` table has been renamed to `highlight`.",
  --     "See :h nvim-surround.config.highlight for details",
  --   }
  --   vim.notify_once(table.concat(highlight_warning, "\n"), vim.log.levels.ERROR)
  -- end
  return opts
end


return M
