" ==============================================================================
"  editing.vim — pairs, text objects, undo, clipboard, whitespace, large files
" ==============================================================================

" ── Auto-pairs (lexima) ───────────────────────────────────────────────────────
" <CR> is shared with completion; the combined mapping lives in lsp.vim.
let g:lexima_accept_pum_with_enter = 0
let g:lexima_enable_endwise_rules  = 1          " if → endif, def → end, …
let g:lexima_ctrlh_as_backspace    = 1

" ── Surround / commentary / targets ──────────────────────────────────────────
" Defaults are kept (ys/cs/ds, gc, ia/aa …) — see README › Plugin defaults.
let g:targets_seekRanges = 'cc cr cb cB lc ac Ac lr rr ll lb ar ab lB Ar aB Ab AB rb al rB Al bb aa bB Aa BB AA'

" ── File commands (vim-eunuch) ────────────────────────────────────────────────
" :Rename :Move :Copy :Delete :Remove :Chmod :Mkdir :SudoWrite …; new files
" that start with a shebang become executable on first write. Its insert-mode
" <CR> wrapper is disabled: <CR> belongs to completion + lexima (lsp.vim).
let g:eunuch_no_maps = 1

" ── Live :substitute preview (traces.vim) ─────────────────────────────────────
" Shows matches and the replacement while you type :s/…/…/ (also :g, :v,
" :sort and ranges). Stays off for huge files to keep typing instant.
let g:traces_num_range_preview = 1
let g:traces_timeout            = 400        " ms; previews that take longer are skipped
let g:traces_skip_modifiers     = 1

" ── Undo tree ─────────────────────────────────────────────────────────────────
let g:undotree_WindowLayout       = 2           " tree left, diff below
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_ShortIndicators    = 1
let g:undotree_SplitWidth         = 34
let g:undotree_HelpLine           = 0

" ── System clipboard ──────────────────────────────────────────────────────────
" This Vim is built without +clipboard, so the "+ register does not exist.
" my#clip bridges to wl-copy / xclip / xsel (or OSC 52 over SSH) instead.
augroup my_clipboard
  autocmd!
  autocmd TextYankPost * if g:my_clipboard_sync && v:event.operator ==# 'y' && v:event.regname ==# ''
        \ | call my#clip#copy(join(v:event.regcontents, "\n") . (v:event.regtype ==# 'V' ? "\n" : ''))
        \ | endif
augroup END

" ── Editing autocommands ──────────────────────────────────────────────────────
augroup my_editing
  autocmd!
  " Create missing parent directories on first write (:e new/dir/file.py).
  autocmd BufWritePre * call my#edit#mkdir_on_write(expand('<afile>'))
  " Lean mode for huge files: no syntax, folds, undo file, swap, LSP, git signs.
  autocmd BufReadPre * call my#edit#large_file_check(expand('<afile>'))
  " Strip trailing whitespace on save for C and Python
  " (toggle all on-save formatting with <Space>tf).
  autocmd BufWritePre *.c,*.h,*.cpp,*.hpp,*.py,*.pyx if g:my_format_on_save | call my#edit#trim_whitespace() | endif
augroup END

" Initialise lexima now (its rules otherwise load on first InsertEnter, which
" would overwrite the completion-aware <CR> defined in lsp.vim).
if my#core#has('lexima.vim')
  autocmd my_editing VimEnter * ++once silent! call lexima#init() | call my#complete#map_cr()
endif

" ── Commands ──────────────────────────────────────────────────────────────────
command! TrimWhitespace call my#edit#trim_whitespace()
command! -bang BufDelete call my#edit#buf_delete(<bang>0)
command! BufOnly call my#edit#buf_only()
command! -nargs=? -complete=file SessionSave call my#session#save(<q-args>)
command! -nargs=? -complete=file SessionLoad call my#session#load(<q-args>)
command! SessionDelete call my#session#delete()
