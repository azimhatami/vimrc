" ==============================================================================
"  whichkey.vim — discoverability: press <Space> and pause to see every group
"  The menu is generated from the mapping registry, so it can never drift
"  from the real mappings.
" ==============================================================================

command! Cheatsheet call my#keys#cheatsheet()
command! -nargs=? -complete=custom,my#help#topics Guide call my#help#open(<q-args>)
command! ThemePreview call my#ui#preview()
command! -nargs=? -complete=customlist,my#ui#theme_names Theme call my#ui#set(<q-args>)
command! KeymapMarkdown call my#health#keymap_markdown()
command! VimHealth call my#health#report()
command! ConfigUpdate call my#health#update_plugins()
command! ConfigSnapshot call my#health#snapshot()

if !my#core#has('vim-which-key')
  finish
endif

let [g:which_key_map, g:which_key_map_visual] = my#keys#which_key_dicts()

let g:which_key_use_floating_win = 1
let g:which_key_floating_relative_win = 0
let g:which_key_sep               = '→'
let g:which_key_hspace            = 4
let g:which_key_centered          = 1
let g:which_key_sort_horizontal   = 0
let g:which_key_fallback_to_native_key = 1
let g:which_key_disable_default_offset = 1
let g:which_key_display_names     = {' ': 'Space', '<Space>': 'Space', '<TAB>': 'Tab', '<CR>': 'Enter', '<C-H>': 'BS'}
" Only show what's in the registry (hides stray plugin <leader> maps).
let g:which_key_ignore_outside_mappings = 0

augroup my_which_key
  autocmd!
  autocmd VimEnter * call which_key#register('<Space>', 'g:which_key_map', 'n')
        \ | call which_key#register('<Space>', 'g:which_key_map_visual', 'v')
  autocmd FileType which_key setlocal nonumber norelativenumber nolist signcolumn=no
augroup END

nnoremap <silent> <leader> :<C-u>WhichKey '<Space>'<CR>
xnoremap <silent> <leader> :<C-u>WhichKeyVisual '<Space>'<CR>
