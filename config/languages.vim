" ==============================================================================
"  languages.vim — per-language settings, formatters, Python/C workflow
" ==============================================================================

augroup my_languages
  autocmd!
  " Indentation / width per language (FileType is more reliable than BufRead
  " patterns: it also covers files detected by shebang or modeline).
  autocmd FileType python            setlocal ts=4 sts=4 sw=4 et tw=79 colorcolumn=+1
  autocmd FileType python            setlocal indentkeys-=<:> indentkeys-=:
  autocmd FileType c,cpp             setlocal ts=4 sts=4 sw=4 et tw=79 colorcolumn=+1 cindent commentstring=//\ %s
  autocmd FileType yaml              setlocal ts=2 sts=2 sw=2 et tw=79 colorcolumn=+1
  autocmd FileType javascript,javascriptreact,typescript,typescriptreact,json,jsonc,html,css,scss,vue,svelte
        \                            setlocal ts=2 sts=2 sw=2 et tw=79 colorcolumn=+1
  autocmd FileType markdown          setlocal ts=2 sts=2 sw=2 et tw=79 colorcolumn=+1 wrap foldmethod=manual
  autocmd FileType haskell,cabal     setlocal ts=2 sts=2 sw=2 et tw=79
  autocmd FileType sh,bash,zsh       setlocal ts=2 sts=2 sw=2 et tw=79 colorcolumn=+1
  autocmd FileType text,rst          setlocal ts=4 sts=4 sw=4 et tw=79
  autocmd FileType go                setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType make              setlocal ts=8 sts=0 sw=8 noet
  autocmd FileType vim               setlocal ts=2 sts=2 sw=2 et
  autocmd FileType gitconfig         setlocal noet
  autocmd FileType json              setlocal conceallevel=0
  " Old syntax overrides
  autocmd BufNewFile,BufRead *.mak   setlocal syntax=html
  " New files you create are always unix line endings.
  autocmd BufNewFile *               setlocal fileformat=unix
augroup END

" PEP 8 hanging indents: one level inside brackets, closing bracket back at
" the statement's indent (Vim's default indents brackets by two levels).
let g:python_indent = {
      \ 'open_paren': 'shiftwidth()', 'nested_paren': 'shiftwidth()',
      \ 'continue': 'shiftwidth()', 'closed_paren_align_last_line': v:false }

" Fenced code blocks highlighted inside Markdown.
let g:markdown_fenced_languages = ['python', 'bash=sh', 'sh', 'javascript', 'js=javascript',
      \ 'typescript', 'ts=typescript', 'json', 'yaml', 'go', 'c', 'vim', 'html', 'css', 'diff']
" g:markdown_folding is left off: its foldexpr (MarkdownFold → synID per line)
" cost ~220 ms when opening a 1000-line README. Markdown uses manual folds.

" ── Prettier ──────────────────────────────────────────────────────────────────
" PrettierAsync runs on save only in projects that have a prettier config file — so it never
" rewrites code in repos that don't use prettier. Toggle with <Space>tf.
let g:prettier#quickfix_enabled         = 0
let g:prettier#autoformat               = 0
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_present = 1
let g:prettier#exec_cmd_async           = 1
augroup my_prettier
  autocmd!
  autocmd BufWritePre *.css,*.scss,*.svelte,*.pcss,*.html,*.ts,*.tsx,*.js,*.jsx,*.json,*.vue
        \ if g:my_format_on_save && exists(':PrettierAsync') == 2 && my#run#has_prettier_config()
        \ |   PrettierAsync
        \ | endif
augroup END

" ── Svelte ───────────────────────────────────────────────────────────────────
let g:vim_svelte_plugin_use_sass          = 1
let g:vim_svelte_plugin_has_init_indent   = 1
let g:vim_svelte_plugin_load_full_syntax  = 1

" ── Auto-close HTML/XML/JSX/Svelte tags (vim-closetag, loaded for these types)
" Type <div> → <div>|</div>.  > after an already-closed tag does nothing extra.
let g:closetag_filenames  = '*.html,*.xhtml,*.xml,*.svelte,*.vue,*.jsx,*.tsx'
let g:closetag_filetypes  = 'html,xhtml,xml,svelte,vue,javascriptreact,typescriptreact'
let g:closetag_xhtml_filetypes = 'xhtml,javascriptreact,typescriptreact,svelte,vue'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
      \ 'typescript.tsx': 'jsxRegion,tsxRegion', 'javascript.jsx': 'jsxRegion',
      \ 'typescriptreact': 'jsxRegion,tsxRegion', 'javascriptreact': 'jsxRegion' }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = ''          " don't take over <leader>> (unused)

" ── Binary files: edit *.bin / *.pcap as hex via xxd ────────────────────────
augroup my_binary
  autocmd!
  autocmd BufReadPre   *.bin,*.pcap let &l:binary = 1
  autocmd BufReadPost  *.bin,*.pcap if &binary | silent %!xxd
  autocmd BufReadPost  *.bin,*.pcap   setlocal filetype=xxd | endif
  autocmd BufWritePre  *.bin,*.pcap if &binary | let b:my_xxd_view = winsaveview() | silent %!xxd -r
  autocmd BufWritePre  *.bin,*.pcap endif
  autocmd BufWritePost *.bin,*.pcap if &binary | silent %!xxd
  autocmd BufWritePost *.bin,*.pcap   setlocal nomodified | call winrestview(get(b:, 'my_xxd_view', {})) | endif
augroup END

" ── Command-line typo guards : :W → :w, :Wa → :wa
cnoreabbrev <expr> W  (getcmdtype() ==# ':' && getcmdline() ==# 'W')  ? 'w'  : 'W'
cnoreabbrev <expr> Wa (getcmdtype() ==# ':' && getcmdline() ==# 'Wa') ? 'wa' : 'Wa'
