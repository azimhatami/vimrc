" ==============================================================================
"  git.vim — fugitive (porcelain) + gitgutter (signs & hunks)
" ==============================================================================

" ── gitgutter ─────────────────────────────────────────────────────────────────
let g:gitgutter_map_keys             = 0       " curated keys in mappings.vim
let g:gitgutter_sign_priority        = 8       " below LSP diagnostics
let g:gitgutter_sign_allow_clobber   = 0
let g:gitgutter_set_sign_backgrounds = 0
let g:gitgutter_sign_added              = '▎'
let g:gitgutter_sign_modified           = '▎'
let g:gitgutter_sign_removed            = '▁'
let g:gitgutter_sign_removed_first_line = '▔'
let g:gitgutter_sign_removed_above_and_below = '▁'
let g:gitgutter_sign_modified_removed   = '▎'
let g:gitgutter_preview_win_floating    = 1
let g:gitgutter_close_preview_on_escape = 1
let g:gitgutter_show_msg_on_hunk_jumping = 0
let g:gitgutter_floating_window_options = {
      \ 'line': 'cursor+1', 'col': 'cursor', 'moved': 'any',
      \ 'border': [1, 1, 1, 1], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
      \ 'borderhighlight': ['FloatBorder'], 'highlight': 'Pmenu', 'padding': [0, 1, 0, 1] }

" ── fugitive ──────────────────────────────────────────────────────────────────
augroup my_git
  autocmd!
  " In :Git status: q closes, ? shows fugitive's own key help.
  autocmd FileType fugitive,fugitiveblame,git setlocal nonumber norelativenumber signcolumn=no nolist
  autocmd FileType fugitive nnoremap <buffer><silent><nowait> q :close <Bar> call my#find#main_window()<CR>
  " Commit messages: spell check + 72-column body.
  autocmd FileType gitcommit setlocal spell textwidth=72 colorcolumn=+1
augroup END

command! GitBlameLine call my#git#blame_line()
