" ==============================================================================
"   vimrc — entry point  (~/.vim/vimrc; ~/.vimrc may be a symlink to it)
"
"   A modular Vim 9 configuration. This file only sets the few things every
"   module depends on, then sources ~/.vim/config/*.vim in a fixed order.
"
"   Docs:      ~/.vim/README.md, ~/.vim/docs/GUIDE.md  (<Space>hr inside Vim)
"   Help:      :Guide                  (or press  <Space>hc)
"   Health:    :VimHealth              (or press  <Space>hh)
" ==============================================================================

if v:version < 900
  echohl WarningMsg | echom 'This configuration needs Vim 9.0+ (found ' . v:version . ').' | echohl None
  finish
endif

let g:my_start_time = reltime()      " shown on the start screen ("ready in N ms")

set nocompatible
set encoding=utf-8
scriptencoding utf-8

" Leader keys must be set before any mapping is defined.
let g:mapleader      = "\<Space>"
let g:maplocalleader = '\'

" ── Feature switches ──────────────────────────────────────────────────────────
" Override any of these in ~/.vim/local.vim (sourced first, so they take effect).
"   g:my_icons            1 = Nerd Font glyphs, 0 = plain Unicode symbols
"   g:my_theme            'space' (Space Vim Dark, default), 'dark' (Catppuccin
"                         Mocha) or 'light' (Catppuccin Latte)
"   g:my_space_background 'default' | 'darker' | 'darkest' (Space Vim Dark only)
"   g:my_dashboard        start screen when Vim opens without files (1/0)
"   g:my_format_on_save   format/trim supported filetypes when writing
"   g:my_clipboard_sync   copy every yank to the system clipboard
"   g:my_largefile_mb     files bigger than this open in "lean" mode
let g:my_icons          = get(g:, 'my_icons', -1)
let g:my_theme          = get(g:, 'my_theme', 'space')
let g:my_dashboard      = get(g:, 'my_dashboard', 1)
let g:my_format_on_save = get(g:, 'my_format_on_save', 1)
let g:my_clipboard_sync = get(g:, 'my_clipboard_sync', 1)
let g:my_largefile_mb   = get(g:, 'my_largefile_mb', 2)

let g:my_config_dir = expand('~/.vim/config')
let g:my_state_dir  = expand('~/.vim/state')
let g:my_errors     = []

" Machine-specific overrides (optional, never overwritten by this config).
if filereadable(expand('~/.vim/local.vim'))
  execute 'source' fnameescape(expand('~/.vim/local.vim'))
endif

" Auto-detect a Nerd Font in the user font directory when not set explicitly.
if g:my_icons == -1
  let g:my_icons = !empty(glob('~/.local/share/fonts/**/*Nerd*', 0, 1))
        \ || !empty(glob('~/.fonts/**/*Nerd*', 0, 1))
endif

" ── Load modules ──────────────────────────────────────────────────────────────
" Order matters: options → plugins → plugin configs → mappings (needs all) →
" which-key (reads the mapping registry). dashboard.vim (start screen) comes
" right after navigation.vim (explorer) because the two open together.
for s:module in ['options', 'plugins', 'appearance', 'navigation', 'dashboard',
      \          'editing', 'git', 'lsp', 'languages', 'mappings', 'whichkey']
  let s:file = g:my_config_dir . '/' . s:module . '.vim'
  if !filereadable(s:file)
    call add(g:my_errors, 'missing module: ' . s:file)
    continue
  endif
  try
    execute 'source' fnameescape(s:file)
  catch
    " One broken module must never take the whole editor down.
    call add(g:my_errors, s:module . '.vim: ' . v:exception . ' @ ' . v:throwpoint)
  endtry
endfor
unlet! s:module s:file

" Report module errors once the UI is up (and not in silent/batch mode).
augroup my_startup_report
  autocmd!
  autocmd VimEnter * call my#core#report_errors()
augroup END
