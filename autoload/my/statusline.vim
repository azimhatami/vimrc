" ==============================================================================
"  my#statusline — lightline components
"  Every function is cheap: no shell calls, results come from plugin caches.
" ==============================================================================

let s:i = g:my_icons
" Icons are written as codepoint escapes (\uXXXX) so the file stays plain
" text and no editor or tool can silently strip Private Use Area glyphs.
" Line continuations cannot carry trailing comments, so names are listed here:
"   branch U+E0A0 · error U+F057 · warning U+F071 · info U+F05A · hint U+F0335
"   lsp U+F085 · line U+E0A1 · folder U+F07B · lock U+F033E · tab U+F04E9
let s:sym = {
      \ 'branch':   s:i ? "\ue0a0 " : '⎇ ',
      \ 'modified': s:i ? ' ●' : ' ●',
      \ 'readonly': s:i ? " \U000f033e" : ' [RO]',
      \ 'error':    s:i ? "\uf057 " : '✘ ',
      \ 'warning':  s:i ? "\uf071 " : '▲ ',
      \ 'information': s:i ? "\uf05a " : '● ',
      \ 'hint':     s:i ? "\U000f0335 " : '◆ ',
      \ 'lsp':      s:i ? "\uf085 " : 'lsp:',
      \ 'line':     s:i ? "\ue0a1 " : '',
      \ 'tab':      s:i ? "\U000f04e9 " : 'tab ',
      \ 'folder':   s:i ? "\uf07b " : '',
      \ }

" Special windows get a friendly label instead of a mode.
let s:special = {
      \ 'fern': 'EXPLORER', 'fugitive': 'GIT', 'fugitiveblame': 'BLAME', 'git': 'GIT',
      \ 'gitcommit': 'COMMIT', 'help': 'HELP', 'qf': 'LIST', 'undotree': 'UNDO',
      \ 'diff': 'DIFF', 'fzf': 'FZF', 'man': 'MAN', 'vim-plug': 'PLUGINS', 'which_key': 'KEYS',
      \ 'mycheatsheet': 'CHEATSHEET', 'myhealth': 'HEALTH', 'startify': 'DASHBOARD',
      \ 'vista': 'OUTLINE', 'vista_kind': 'OUTLINE' }

function! my#statusline#_sym(name) abort
  return get(s:sym, a:name, '')
endfunction

function! s:is_special() abort
  return has_key(s:special, &filetype) || &buftype ==# 'terminal'
endfunction

function! s:narrow(...) abort
  return winwidth(0) < (a:0 ? a:1 : 70)
endfunction

function! my#statusline#mode() abort
  if &buftype ==# 'terminal'
    return mode() ==# 't' ? 'TERMINAL' : 'TERM·NORMAL'
  endif
  if has_key(s:special, &filetype)
    return &filetype ==# 'qf' && getwininfo(win_getid())[0].loclist ? 'LOCLIST' : s:special[&filetype]
  endif
  let l:m = lightline#mode()
  return s:narrow(50) ? l:m[0] : l:m
endfunction

function! my#statusline#git() abort
  if s:is_special() || s:narrow() || !exists('*FugitiveHead')
    return ''
  endif
  let l:head = FugitiveHead(7)
  if empty(l:head) | return '' | endif
  let l:out = s:sym.branch . l:head
  if exists('*GitGutterGetHunkSummary')
    let [l:a, l:m, l:r] = GitGutterGetHunkSummary()
    let l:out .= (l:a ? ' +' . l:a : '') . (l:m ? ' ~' . l:m : '') . (l:r ? ' -' . l:r : '')
  endif
  return l:out
endfunction

function! my#statusline#filename() abort
  if &buftype ==# 'terminal'
    return substitute(bufname(), '^!', '', '')
  endif
  if &filetype ==# 'fern'
    return fnamemodify(getcwd(), ':~')
  endif
  if &filetype ==# 'help'
    return expand('%:t:r')
  endif
  if &filetype ==# 'qf'
    return get(w:, 'quickfix_title', '')
  endif
  if s:is_special()
    return ''
  endif
  let l:name = expand('%:~:.')
  if empty(l:name)
    let l:name = '[No Name]'
  elseif strdisplaywidth(l:name) > winwidth(0) / 2
    let l:name = pathshorten(l:name)
  endif
  let l:icon = s:i && exists('*nerdfont#find') ? nerdfont#find() . ' ' : ''
  return l:icon . l:name . (&modified ? s:sym.modified : '') . (&readonly || !&modifiable ? s:sym.readonly : '')
endfunction

" Diagnostics (component_expand → coloured by type). Refreshed on LSP events.
function! s:diag(kind) abort
  if !exists('*lsp#get_buffer_diagnostics_counts') || s:is_special()
    return ''
  endif
  let l:n = get(lsp#get_buffer_diagnostics_counts(), a:kind, 0)
  return l:n ? s:sym[a:kind] . l:n : ''
endfunction
function! my#statusline#errors() abort
  return s:diag('error')
endfunction
function! my#statusline#warnings() abort
  return s:diag('warning')
endfunction
function! my#statusline#infos() abort
  return join(filter([s:diag('information'), s:diag('hint')], '!empty(v:val)'), ' ')
endfunction

let s:short_names = {'pyright-langserver': 'pyright', 'typescript-language-server': 'tsserver',
      \ 'bash-language-server': 'bashls', 'yaml-language-server': 'yamlls'}

" Active language servers for this buffer (cached per buffer, refreshed on events).
function! my#statusline#lsp() abort
  if s:is_special() || s:narrow(90) || !exists('*lsp#get_allowed_servers')
    return ''
  endif
  let l:running = filter(lsp#get_allowed_servers(), 'lsp#get_server_status(v:val) ==# "running"')
  return empty(l:running) ? '' : s:sym.lsp . join(map(l:running, 'get(s:short_names, v:val, v:val)'), ',')
endfunction

function! my#statusline#filetype() abort
  if s:is_special() | return '' | endif
  if empty(&filetype) | return s:narrow() ? '' : 'plain' | endif
  return &filetype
endfunction

function! my#statusline#fileinfo() abort
  if s:is_special() || s:narrow(100) | return '' | endif
  let l:enc = empty(&fileencoding) ? &encoding : &fileencoding
  return l:enc . (&bomb ? '[BOM]' : '') . ' · ' . &fileformat
endfunction

function! my#statusline#position() abort
  if &filetype ==# 'fern' | return '' | endif
  return s:sym.line . line('.') . ':' . virtcol('.')
endfunction

function! my#statusline#percent() abort
  if &filetype ==# 'fern' | return '' | endif
  let l:l = line('.')
  let l:n = line('$')
  return l:l == 1 ? 'Top' : l:l == l:n ? 'Bot' : (l:l * 100 / l:n) . '%'
endfunction

" Tabline extras
function! my#statusline#cwd() abort
  let l:cwd = fnamemodify(getcwd(), ':~')
  if strchars(l:cwd) > 40
    let l:cwd = pathshorten(l:cwd)
  endif
  return s:sym.folder . l:cwd
endfunction

" Buffer line shows real files only (no fugitive://, terminals, explorers…).
function! my#statusline#buffer_filter(buf) abort
  return getbufvar(a:buf, '&buftype') ==# '' && bufname(a:buf) !~# '^\a\+://'
endfunction

function! my#statusline#tabs() abort
  let l:n = tabpagenr('$')
  return l:n > 1 ? s:sym.tab . tabpagenr() . '/' . l:n : ''
endfunction

" Re-read the generated colour scheme (after a theme toggle) and redraw.
function! my#statusline#reload() abort
  if !exists('g:loaded_lightline') | return | endif
  runtime autoload/lightline/colorscheme/my_palette.vim
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

function! my#statusline#refresh() abort
  if exists('g:loaded_lightline') | call lightline#update() | endif
endfunction
