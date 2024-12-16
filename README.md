
# nvim-highlight-hero

`nvim-highlight-hero` is a Neovim plugin designed to interactively highlight words, phrases, and multiline selections. It provides multiple highlight "groups" that can be toggled on and off, as well as an auto-highlight mode for highlighting the word under the cursor.

## Features

- Highlight words or visual selections interactively.
- Manage up to 10 highlight groups (0-9) with ease.
- Toggle auto-highlight mode for highlighting the word under the cursor.
- Define custom highlight colors.

## Installation

Use your favorite plugin manager. For example, with `packer.nvim`:

```lua
use {
  'yourusername/nvim-highlight-hero',
  config = function()
    require('nvim-highlight-hero').setup()
  end
}
```

## Usage

### Commands

- `:HH`: Toggle auto-highlight mode.
- `:HH off`: Turn off all highlights and disable auto-highlight mode.
- `:HH <num>`: Highlight with a specific group (e.g., `:HH 2`).
- `:HH <num> off`: Remove highlights from a specific group (e.g., `:HH 2 off`).

### Default Keymaps

#### Normal Mode
- `<num>m`: Highlight the current word with boundaries (e.g., `1m` highlights with group 1).
- `<num>M`: Append the highlight for the current word (e.g., `1M` appends to group 1).
- Repeating `<num>m` (e.g., `1m1m`) toggles the highlight for that group off.

#### Visual Mode
- `<num>m`: Highlight the visual selection.
- `<num>M`: Append the highlight for the visual selection.

### Highlight Groups

Define or override the highlight groups to use custom colors. By default, the following highlight groups are linked:

```vim
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
```

## Configuration

You can configure the plugin using the `setup` function. Example:

```lua
require('nvim-highlight-hero').setup({
  keymaps = {
    toggle_auto_highlight = '<leader>hh',
    normal_match_1 = '1m',
    visual_match_1 = '1m',
  },
  highlight = {
    duration = 300, -- Duration in milliseconds for highlights
  },
})
```

## Contributing

Feel free to submit issues or pull requests on the GitHub repository. Contributions are welcome!

## License

This plugin is released under the MIT License.
