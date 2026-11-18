" ==============================================================================
"  appearance.vim — theme, status line, buffer line, visual polish
" ==============================================================================

" ── Colour scheme ─────────────────────────────────────────────────────────────
augroup my_colors
  autocmd!
  autocmd ColorScheme * call my#ui#generic_overrides()
  autocmd ColorScheme catppuccin*,space-vim-dark call my#ui#overrides()
augroup END

syntax enable
let g:my_default_theme = g:my_theme       " what Space t R / :Theme restore
call my#ui#apply_theme(g:my_theme)

" ── Status line + buffer line (lightline) ────────────────────────────────────
if my#core#has('lightline.vim')
  " Rounded pill caps U+E0B4 / U+E0B6 with a Nerd Font; flat blocks otherwise.
  let s:sep = g:my_icons
        \ ? {'separator': {'left': "\ue0b4", 'right': "\ue0b6"}, 'subseparator': {'left': '', 'right': ''}}
        \ : {'separator': {'left': '', 'right': ''}, 'subseparator': {'left': '', 'right': ''}}

  let g:lightline = extend({
        \ 'colorscheme': 'my_palette',
        \ 'active': {
        \   'left':  [ ['mode', 'paste'], ['git'], ['filename'] ],
        \   'right': [ ['position'], ['percent'],
        \              ['errors', 'warnings', 'infos', 'lsp', 'filetype', 'fileinfo'] ] },
        \ 'inactive': {
        \   'left':  [ ['filename'] ],
        \   'right': [ ['position'] ] },
        \ 'tabline': {
        \   'left':  [ ['buffers'] ],
        \   'right': [ ['tabs'], ['cwd'] ] },
        \ 'component_function': {
        \   'mode':     'my#statusline#mode',
        \   'git':      'my#statusline#git',
        \   'filename': 'my#statusline#filename',
        \   'filetype': 'my#statusline#filetype',
        \   'fileinfo': 'my#statusline#fileinfo',
        \   'position': 'my#statusline#position',
        \   'percent':  'my#statusline#percent',
        \   'cwd':      'my#statusline#cwd' },
        \ 'component_expand': {
        \   'buffers':  'lightline#bufferline#buffers',
        \   'tabs':     'my#statusline#tabs',
        \   'errors':   'my#statusline#errors',
        \   'warnings': 'my#statusline#warnings',
        \   'infos':    'my#statusline#infos',
        \   'lsp':      'my#statusline#lsp' },
        \ 'component_type': {
        \   'buffers':  'tabsel',
        \   'tabs':     'right',
        \   'errors':   'error',
        \   'warnings': 'warning',
        \   'infos':    'info',
        \   'lsp':      'lsp' },
        \ 'component_raw': { 'buffers': 1 },
        \ }, s:sep)

  " Buffer line: ordinal numbers match  <Space>1 … <Space>9
  let g:lightline#bufferline#show_number      = 2
  let g:lightline#bufferline#ordinal_number_map = {
        \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
  let g:lightline#bufferline#number_separator = ' '
  let g:lightline#bufferline#modified         = ' ●'
  let g:lightline#bufferline#read_only        = g:my_icons ? " \U000f033e" : ' [RO]'
  let g:lightline#bufferline#unnamed          = '[No Name]'
  let g:lightline#bufferline#smart_path       = 1
  let g:lightline#bufferline#min_buffer_count = 1
  let g:lightline#bufferline#clickable        = 1
  let g:lightline#bufferline#enable_nerdfont  = g:my_icons && my#core#has('vim-nerdfont')
  let g:lightline#bufferline#icon_position    = 'left'
  let g:lightline#bufferline#unicode_symbols  = 1
  let g:lightline#bufferline#margin_left      = 1
  let g:lightline#bufferline#margin_right     = 1
  let g:lightline#bufferline#buffer_filter    = 'my#statusline#buffer_filter'
  unlet s:sep
else
  " Built-in fallback status line (no plugin required).
  set statusline=\ %{mode()}\ │\ %<%f\ %m%r%=%y\ %{&fenc}\ │\ %l:%v\ %P\
endif

" ── Distraction-free mode ────────────────────────────────────────────────────
let g:goyo_width  = 100
let g:goyo_height = '90%'

" ── Visual autocommands ───────────────────────────────────────────────────────
augroup my_appearance
  autocmd!
  " Indent guides follow each buffer's shiftwidth.
  autocmd BufWinEnter,FileType * call my#ui#listchars()
  autocmd OptionSet shiftwidth,tabstop,expandtab call my#ui#listchars()
  " Cursor line + relative numbers only in the focused window.
  autocmd WinEnter,BufWinEnter,FocusGained * if &filetype !=# 'fern' | setlocal cursorline | endif | call my#ui#numbers(1)
  autocmd WinLeave,FocusLost * if &filetype !=# 'fern' | setlocal nocursorline | endif | call my#ui#numbers(0)
  autocmd InsertEnter * call my#ui#numbers(0)
  autocmd InsertLeave * call my#ui#numbers(1)
  " Trailing-whitespace highlight (ignores the spot you are typing at).
  autocmd BufWinEnter,WinEnter,InsertLeave * call my#ui#whitespace(0)
  autocmd InsertEnter * call my#ui#whitespace(1)
  " Flash yanked text.
  autocmd TextYankPost * call my#ui#yank_flash()
  " Keep the status line fresh after LSP / git updates.
  autocmd User lsp_diagnostics_updated,lsp_server_init,lsp_server_exit,GitGutter call my#statusline#refresh()
  " Goyo hooks.
  autocmd User GoyoEnter nested call my#ui#goyo_enter()
  autocmd User GoyoLeave nested call my#ui#goyo_leave()
  " Terminal windows: no numbers/guides. Guarded on &buftype because pop-up
  " terminals (fzf) fire TerminalOpen while the *editor* window is current.
  autocmd TerminalOpen * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber signcolumn=no nolist nocursorline | endif
augroup END

if exists('##TerminalWinOpen')
  autocmd my_appearance TerminalWinOpen * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber signcolumn=no | endif
endif
