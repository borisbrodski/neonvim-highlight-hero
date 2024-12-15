local engine = require("nvim-highlight-hero.engine")
local M = {}

-- Define default mappings:
-- For 0..9:
-- Normal mode:
--   <num>m -> highlight current word with boundaries
--   <num>M -> append current word with boundaries
-- Visual mode:
--   <num>m -> highlight visual selection (no boundaries)
--   <num>M -> append visual selection (no boundaries)
local function add_numbered_mappings(opts)
	for i = 0, 9 do
		-- Normal mode mappings
		opts.keymaps[string.format("normal_match_%d", i)] = string.format("%dm", i)
		opts.keymaps[string.format("normal_match_append_%d", i)] = string.format("%dM", i)

		-- Visual mode mappings (can use the same keys)
		opts.keymaps[string.format("visual_match_%d", i)] = string.format("%dm", i)
		opts.keymaps[string.format("visual_match_append_%d", i)] = string.format("%dM", i)
	end
	return opts
end

local default_opts = add_numbered_mappings({
	keymaps = {
		toggle_auto_highlight = "<leader>hh",
	},
	disable_filetype = { "TelescopePrompt", "spectre_panel" },
})

-- Generic function to set all keymaps
---@param buffer boolean whether the keymaps should be set for the buffer or not.
function M.set_keymaps(buffer)
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

	-- Now set the number-based mappings for normal and visual mode
	for i = 0, 9 do
		local normal_match = M.get_opts().keymaps[string.format("normal_match_%d", i)]
		local normal_match_append = M.get_opts().keymaps[string.format("normal_match_append_%d", i)]
		local visual_match = M.get_opts().keymaps[string.format("visual_match_%d", i)]
		local visual_match_append = M.get_opts().keymaps[string.format("visual_match_append_%d", i)]

		-- Normal mode: <num>m (no append), highlight word with boundaries
		M.set_keymap({
			name = string.format("Highlight current word with color %d", i),
			mode = "n",
			lhs = normal_match,
			rhs = function()
				engine.match(i, false, true) -- true for keep_visual doesn't matter in normal mode
			end,
			opts = {
				buffer = buffer,
				desc = string.format("Highlight current word with color %d", i),
				silent = true,
			},
		})

		-- Normal mode: <num>M (append), highlight word with boundaries
		M.set_keymap({
			name = string.format("Append highlight current word with color %d", i),
			mode = "n",
			lhs = normal_match_append,
			rhs = function()
				engine.match(i, true, true)
			end,
			opts = {
				buffer = buffer,
				desc = string.format("Append highlight current word with color %d", i),
				silent = true,
			},
		})

		-- Visual mode: <num>m (no append), highlight selection without boundaries
		M.set_keymap({
			name = string.format("Highlight selection with color %d", i),
			mode = "v",
			lhs = visual_match,
			rhs = function()
				engine.match(i, false, false) -- In visual mode, engine.match() will not use boundaries
			end,
			opts = {
				buffer = buffer,
				desc = string.format("Highlight selection with color %d", i),
				silent = true,
			},
		})

		-- Visual mode: <num>M (append), highlight selection without boundaries
		M.set_keymap({
			name = string.format("Append highlight selection with color %d", i),
			mode = "v",
			lhs = visual_match_append,
			rhs = function()
				engine.match(i, true, false) -- append mode in visual
			end,
			opts = {
				buffer = buffer,
				desc = string.format("Append highlight selection with color %d", i),
				silent = true,
			},
		})
	end
end

-- Check if a keymap should be added before setting it.
---@param args table The arguments to set the keymap.
function M.set_keymap(args)
	-- If the keymap is disabled
	if not args.rhs then
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
	M.user_opts = M.merge_opts(M.translate_opts(default_opts), user_opts)
	M.set_keymaps(false)

	vim.cmd([[
    highlight default link NvimHighlightHeroAuto Search
    highlight default link NvimHighlightHeroMatch1 DiffText
    highlight default link NvimHighlightHeroMatch2 Substitute
    highlight default link NvimHighlightHeroMatch3 SpellBad
    highlight default link NvimHighlightHeroMatch4 FoldColumn
    highlight default link NvimHighlightHeroMatch5 Folded
    highlight default link NvimHighlightHeroMatch6 TermCursor
    highlight default link NvimHighlightHeroMatch7 DiffDelete
    highlight default link NvimHighlightHeroMatch8 WildMenu
    highlight default link NvimHighlightHeroMatch9 IncSearch
    highlight default link NvimHighlightHeroMatch0 TODO
  ]])

	local group_id = vim.api.nvim_create_augroup("HighlightHero", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		pattern = "*",
		callback = function()
			require("nvim-highlight-hero").on_cursor_moved()
		end,
		group = group_id,
	})

	vim.api.nvim_create_autocmd("ModeChanged", {
		pattern = "*:V", -- from any mode to V (linewise visual)
		callback = function()
			require("nvim-highlight-hero").on_cursor_moved()
		end,
		group = group_id,
	})
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
	return opts
end

return M
