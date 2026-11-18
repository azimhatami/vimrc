" ==============================================================================
"  lsp.vim — language servers (vim-lsp + vim-lsp-settings) and completion
"
"  Servers live in ~/.local/share/vim-lsp-settings/servers (user-local).
"  Install another one:  open a file of that language →  :LspInstallServer
" ==============================================================================

if !my#core#has('vim-lsp')
  finish
endif

let s:i = g:my_icons

" ── Client behaviour ──────────────────────────────────────────────────────────
let g:lsp_use_native_client          = has('patch-8.2.4780')   " Vim's built-in LSP channel (faster JSON)
let g:lsp_max_buffer_size            = g:my_largefile_mb * 1024 * 1024
let g:lsp_semantic_enabled           = 0       " Catppuccin + syntax already do this, cheaper
let g:lsp_document_code_action_signs_enabled = 0   " no lightbulb noise
let g:lsp_document_highlight_enabled = 1       " highlight other uses of the symbol under cursor
let g:lsp_document_highlight_delay   = 300
let g:lsp_format_sync_timeout        = 1500
let g:lsp_signature_help_enabled     = 1       " parameter hints while typing a call
let g:lsp_signature_help_delay       = 120
let g:lsp_completion_documentation_enabled = 1
let g:lsp_work_done_progress_enabled = 0
let g:lsp_show_message_log_level     = 'warning'
let g:lsp_inlay_hints_enabled        = 0       " toggle per session with :let g:lsp_inlay_hints_enabled = 1
let g:lsp_hover_ui                   = 'float'
let g:lsp_preview_float              = 1
let g:lsp_preview_max_width          = 90
let g:lsp_preview_max_height         = 22
let g:lsp_float_max_width            = 90
let g:lsp_popup_borderchars          = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']

" ── Diagnostics ───────────────────────────────────────────────────────────────
let g:lsp_diagnostics_enabled                     = 1
let g:lsp_diagnostics_signs_enabled               = 1
let g:lsp_diagnostics_signs_priority              = 11
let g:lsp_diagnostics_signs_insert_mode_enabled   = 0
let g:lsp_diagnostics_highlights_enabled          = 1
let g:lsp_diagnostics_highlights_insert_mode_enabled = 0
let g:lsp_diagnostics_virtual_text_enabled        = 1
let g:lsp_diagnostics_virtual_text_insert_mode_enabled = 0
let g:lsp_diagnostics_virtual_text_align          = 'after'
let g:lsp_diagnostics_virtual_text_padding_left   = 3
let g:lsp_diagnostics_virtual_text_wrap           = 'truncate'
let g:lsp_diagnostics_virtual_text_prefix         = s:i ? '■ ' : '◆ '
let g:lsp_diagnostics_echo_cursor                 = 1   " full message in the command line
let g:lsp_diagnostics_echo_delay                  = 250
let g:lsp_diagnostics_float_cursor                = 0
" Sign glyphs as codepoint escapes: U+F057 times-circle, U+F071 warning,
" U+F05A info-circle, U+F0335 lightbulb (Nerd Font); Unicode fallbacks after ':'.
let g:lsp_diagnostics_signs_error       = {'text': s:i ? "\uf057" : '✘'}
let g:lsp_diagnostics_signs_warning     = {'text': s:i ? "\uf071" : '▲'}
let g:lsp_diagnostics_signs_information = {'text': s:i ? "\uf05a" : '●'}
let g:lsp_diagnostics_signs_hint        = {'text': s:i ? "\U000f0335" : '◆'}

" ── Servers (vim-lsp-settings) ────────────────────────────────────────────────
" Pin one server per language so nothing unexpected is offered or started.
let g:lsp_settings_filetype_python          = ['pyright-langserver']
let g:lsp_settings_filetype_javascript      = ['typescript-language-server']
let g:lsp_settings_filetype_javascriptreact = ['typescript-language-server']
let g:lsp_settings_filetype_typescript      = ['typescript-language-server']
let g:lsp_settings_filetype_typescriptreact = ['typescript-language-server']
let g:lsp_settings_filetype_sh              = ['bash-language-server']
let g:lsp_settings_filetype_yaml            = ['yaml-language-server']
let g:lsp_settings_filetype_go              = ['gopls']
let g:lsp_settings_filetype_c               = ['clangd']
let g:lsp_settings_filetype_cpp             = ['clangd']
" Don't nag about servers for other languages (install them on demand instead).
let g:lsp_settings_enable_suggestions = 0

let g:lsp_settings = {
      \ 'pyright-langserver': { 'workspace_config': {name, key -> {server_info -> my#lsp#pyright_settings()}} },
      \ 'gopls': { 'initialization_options': { 'usePlaceholders': v:false, 'staticcheck': v:false } },
      \ 'clangd': { 'cmd': {server_info -> [lsp_settings#exec_path('clangd'), '--background-index', '--clang-tidy', '--header-insertion=never']} },
      \ 'yaml-language-server': { 'workspace_config': { 'yaml': {
      \     'keyOrdering': v:false, 'format': { 'enable': v:true }, 'schemaStore': { 'enable': v:true } } } },
      \ }

" pyright settings are computed per request (a lambda returning a lambda:
" vim-lsp-settings evaluates the outer one once, vim-lsp calls the inner one
" whenever pyright asks), so `python.pythonPath` always points at the
" project's virtualenv — imports from .venv/venv resolve. See my#lsp.

" ── Per-buffer setup when a server attaches ───────────────────────────────────
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal tagfunc=lsp#tagfunc          " <C-]> and :tag jump to definitions
  setlocal signcolumn=yes
  " Native-style goto keys, overridden only in buffers with a server attached.
  nmap <buffer> gd <Plug>(lsp-definition)
  nmap <buffer> gD <Plug>(lsp-declaration)
  nmap <buffer> gr <Plug>(lsp-references)
  nmap <buffer> gI <Plug>(lsp-implementation)
  nmap <buffer> gy <Plug>(lsp-type-definition)
  nmap <buffer> K  <Plug>(lsp-hover)
  nmap <buffer> [d <Plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <Plug>(lsp-next-diagnostic)
  " Scroll a hover/preview popup without entering it.
  " (only while a pop-up is open; otherwise they page as usual)
  nnoremap <buffer><expr> <C-f> my#complete#scroll(+4, "\<C-f>")
  nnoremap <buffer><expr> <C-b> my#complete#scroll(-4, "\<C-b>")
  let b:my_lsp_attached = 1
endfunction

augroup my_lsp
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  " Format on save where a server owns formatting (Go: gofmt via gopls).
  autocmd BufWritePre *.go if g:my_format_on_save && get(b:, 'my_lsp_attached', 0) | silent! LspDocumentFormatSync | endif
augroup END

" ── Completion (asyncomplete) ─────────────────────────────────────────────────
if my#core#has('asyncomplete.vim')
  let g:asyncomplete_auto_popup       = 1
  let g:asyncomplete_auto_completeopt = 0       " we set completeopt ourselves
  let g:asyncomplete_popup_delay      = 40
  let g:asyncomplete_min_chars        = 2
  let g:asyncomplete_preprocessor     = [function('my#complete#preprocess')]

  function! s:register_sources() abort
    if my#core#has('asyncomplete-buffer.vim')
      call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
            \ 'name': 'buffer', 'allowlist': ['*'], 'blocklist': ['go'],
            \ 'priority': 1,
            \ 'completor': function('asyncomplete#sources#buffer#completor'),
            \ 'config': { 'max_buffer_size': 2000000 } }))
    endif
    if my#core#has('asyncomplete-file.vim')
      call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
            \ 'name': 'file', 'allowlist': ['*'], 'priority': 10,
            \ 'completor': function('asyncomplete#sources#file#completor') }))
    endif
  endfunction

  augroup my_complete
    autocmd!
    autocmd User asyncomplete_setup call s:register_sources()
    " No completion pop-ups in prompts and tool buffers.
    autocmd FileType fern,fzf,fugitive,gitcommit,undotree,which_key,myguide let b:asyncomplete_enable = 0
  augroup END
endif

" ── Snippets (vim-vsnip) ──────────────────────────────────────────────────────
" VS Code-format snippets: friendly-snippets (all languages) + your own in
" ~/.vim/snippets/<filetype>.json (Space c s edits the current filetype's).
" LSP snippet completions (function signatures…) expand via vsnip-integ.
" Keys (insert/select mode, defined in mappings.vim):
"   <C-j>  expand the snippet before the cursor, or jump to the next field
"   <C-k>  previous field (only inside a snippet; digraphs work elsewhere)
let g:vsnip_snippet_dir = expand('~/.vim/snippets')
let g:vsnip_filetypes = get(g:, 'vsnip_filetypes', {})
let g:vsnip_filetypes.svelte = ['html', 'javascript', 'typescript', 'css']
let g:vsnip_filetypes.sh = ['shelldoc']
let g:vsnip_filetypes.bash = ['sh']
let g:vsnip_integ_confirm_behavior = 'replace'

" ── Symbol outline (Vista, loaded on first use) ───────────────────────────────
" A right-hand sidebar fed by the language server (no ctags needed).
let g:vista_default_executive    = 'vim_lsp'
let g:vista_sidebar_position     = 'vertical botright'
let g:vista_sidebar_width        = 34
let g:vista_stay_on_open         = 1          " cursor stays in the code (<C-l> enters the outline)
let g:vista_close_on_jump        = 0
let g:vista_blink                = [1, 120]
let g:vista_top_level_blink      = [1, 120]
let g:vista_echo_cursor          = 0          " no command-line chatter while moving
let g:vista_update_on_text_changed = 1
let g:vista_update_on_text_changed_delay = 600
let g:vista_disable_statusline   = 1          " lightline labels it OUTLINE
let g:vista#renderer#enable_icon = g:my_icons
let g:vista_icon_indent          = ['╰─▸ ', '├─▸ ']
let g:vista_fold_toggle_icons    = ['▾', '▸']
augroup my_vista
  autocmd!
  autocmd FileType vista,vista_kind setlocal nonumber norelativenumber signcolumn=no nolist winfixwidth
        \ | nnoremap <buffer><silent><nowait> q :close<CR>
augroup END
