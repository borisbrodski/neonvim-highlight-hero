" Title:        Neovim Highlight Hero
" Description:  The highlight-hero highlights multiple words and visual selections. On the statically and on the fly.
" Maintainer:   Boris Brodski <brodsky_boris@yahoo.com>
" Repository:   https://github.com/borisbrodski/nvim-highlight-hero

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_nvim_highlight_hero")
    finish
endif
let g:loaded_nvim_highlight_hero = 1
"
" command! -bar                         HighlightHeroAuto   call s:highlight_current_toggle()
" command! -bar                         HHauto              call s:highlight_current_toggle()
" command! -bar -bang -count=0 -nargs=? HighlightHero       call s:highlight(<count>, "<bang>", 0, "<args>")
command! -bar -bang -count=0 -nargs=? HH                  lua require("nvim-highlight-hero").command_HH()
" command! -bar -bang -count=0 -nargs=0 HighlightHeroOff    call s:highlight_off_cmd(v:count, "<bang>")
" command! -bar -bang -count=0 -nargs=0 HHoff               call s:highlight_off_cmd(v:count, "<bang>")
" command!                              HighlightHeroPrint  call s:highlight_hero_print()
" command!                              HHprint             call s:highlight_hero_print()
