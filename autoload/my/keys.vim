" ==============================================================================
"  my#keys — mapping registry: ONE place that defines a key AND documents it
"
"    call my#keys#group('f', 'Find & search')
"    call my#keys#map('n', '<leader>ff', ':Files<CR>', 'Find files',
"          \ {'info': 'Fuzzy-find any file', 'ex': 'type "usrctl" → src/user/ctl.ts'})
"    call my#keys#doc('n', 'ys{motion}{char}', 'Add surrounding', {'scope': 'vim-surround'})
"
"  The registry feeds: the which-key menu, :Cheatsheet, README tables
"  (:KeymapMarkdown) and the automated conflict/duplicate test.
" ==============================================================================

let g:my_keys       = get(g:, 'my_keys', [])
let g:my_key_groups = get(g:, 'my_key_groups', [])
let s:seen = {}
let s:group_title = {}

let s:mode_names = {'n': 'Normal', 'x': 'Visual', 'v': 'Visual', 'i': 'Insert', 't': 'Terminal',
      \ 'c': 'Cmdline', 'o': 'Operator', 's': 'Select'}

function! my#keys#group(key, title, ...) abort
  " Optional 3rd arg: one-word label for the which-key menu (default: first word).
  let l:short = a:0 ? a:1 : tolower(matchstr(a:title, '^\w\+'))
  call add(g:my_key_groups, {'key': a:key, 'title': a:title, 'short': l:short})
  let s:group_title[a:key] = a:title
endfunction

" modes: string of mode letters ('n', 'nx', 'i' …)
" opts:  info, ex, cat, cond, remap, expr, nowait, silent(=1)
function! my#keys#map(modes, lhs, rhs, desc, ...) abort
  let l:o = a:0 ? a:1 : {}
  for l:m in split(a:modes, '\zs')
    let l:id = l:m . ':' . a:lhs
    if has_key(s:seen, l:id)
      call my#core#warn('duplicate mapping ' . l:id . ' (' . a:desc . ' vs ' . s:seen[l:id] . ')')
      continue
    endif
    let s:seen[l:id] = a:desc
    let l:cmd = l:m . (get(l:o, 'remap', 0) ? 'map' : 'noremap')
          \ . (get(l:o, 'silent', 1) ? ' <silent>' : '')
          \ . (get(l:o, 'expr', 0) ? ' <expr>' : '')
          \ . (get(l:o, 'nowait', 0) ? ' <nowait>' : '')
          \ . ' ' . a:lhs . ' ' . a:rhs
    execute l:cmd
  endfor
  call s:register(a:modes, a:lhs, a:desc, l:o, 'map')
endfunction

" Documentation-only entry (plugin defaults, buffer-local keys defined elsewhere).
function! my#keys#doc(modes, lhs, desc, ...) abort
  call s:register(a:modes, a:lhs, a:desc, a:0 ? a:1 : {}, 'doc')
endfunction

function! s:register(modes, lhs, desc, o, kind) abort
  call add(g:my_keys, {
        \ 'modes': a:modes, 'lhs': a:lhs, 'desc': a:desc, 'kind': a:kind,
        \ 'info': get(a:o, 'info', ''), 'ex': get(a:o, 'ex', ''),
        \ 'cat': get(a:o, 'cat', s:category(a:lhs)), 'scope': get(a:o, 'scope', ''),
        \ 'cond': get(a:o, 'cond', ''), 'check': get(a:o, 'check', a:kind ==# 'map'),
        \ 'wk': get(a:o, 'wk', '') })
endfunction

function! s:category(lhs) abort
  if a:lhs !~? '^<leader>' | return 'Other' | endif
  " '<leader>' + group key + at least one more key → that group's title.
  let l:rest = a:lhs[8:]
  let l:first = matchstr(l:rest, '^\%(<[^>]\+>\|.\)')
  return strlen(l:rest) > strlen(l:first) ? get(s:group_title, l:first, 'Quick access') : 'Quick access'
endfunction

" '<leader>ff' → ['f', 'f'];  '<leader><Space>' → ['<Space>']
function! s:tokens(lhs) abort
  let l:rest = substitute(a:lhs, '\c^<leader>', '', '')
  return filter(split(l:rest, '\%(<[^>]\+>\|.\)\zs'), '!empty(v:val)')
endfunction

" ── which-key dictionaries (normal + visual) ─────────────────────────────────
function! my#keys#which_key_dicts() abort
  let l:n = {}
  let l:v = {}
  for l:g in g:my_key_groups
    let l:n[l:g.key] = {'name': '+' . l:g.short}
    let l:v[l:g.key] = {'name': '+' . l:g.short}
  endfor
  for l:e in g:my_keys
    if l:e.lhs !~? '^<leader>' | continue | endif
    let l:t = s:tokens(l:e.lhs)
    let l:label = empty(l:e.wk) ? l:e.desc : l:e.wk
    for [l:mode, l:dict] in [['n', l:n], ['x', l:v]]
      if stridx(l:e.modes, l:mode) < 0 | continue | endif
      if len(l:t) == 1
        let l:dict[l:t[0]] = l:label
      elseif len(l:t) == 2 && has_key(l:dict, l:t[0])
        let l:dict[l:t[0]][l:t[1]] = l:label
      endif
    endfor
  endfor
  " Drop groups with no visual-mode members.
  call filter(l:v, 'type(v:val) != v:t_dict || len(v:val) > 1')
  return [l:n, l:v]
endfunction

" ── Human-readable key notation ───────────────────────────────────────────────
function! my#keys#pretty(lhs) abort
  let l:s = substitute(a:lhs, '\c<leader>', '<Space>', 'g')
  return l:s
endfunction

function! s:modes(m) abort
  return join(map(split(a:m, '\zs'), 'get(s:mode_names, v:val, v:val)'), ', ')
endfunction

" Long-form docs: registry fields win; my#keydocs fills the gaps.
function! my#keys#docs(e) abort
  let l:extra = get(my#keydocs#get(), a:e.cat . '|' . a:e.modes . '|' . a:e.lhs, ['', ''])
  return [empty(a:e.info) ? l:extra[0] : a:e.info, empty(a:e.ex) ? l:extra[1] : a:e.ex]
endfunction

" Markdown-safe cell: escape pipes, put <Key> notation in code spans so
" renderers don't swallow it as HTML (cells that already use ` are left alone).
function! s:cell(text) abort
  let l:t = escape(a:text, '|')
  return l:t =~# '`' ? l:t : substitute(l:t, '<[A-Za-z][^<> ]*>\%(<[A-Za-z][^<> ]*>\|[[:alnum:]]\)*', '`&`', 'g')
endfunction

" ── Markdown tables for the README (generated from the live registry) ───────
function! my#keys#markdown() abort
  let l:out = []
  let l:cats = []
  for l:e in g:my_keys
    if index(l:cats, l:e.cat) < 0 | call add(l:cats, l:e.cat) | endif
  endfor
  for l:cat in l:cats
    let l:prefix = ''
    for l:g in g:my_key_groups
      if l:g.title ==# l:cat | let l:prefix = ' — `<Space>' . l:g.key . '`' | endif
    endfor
    call extend(l:out, ['', '#### ' . l:cat . l:prefix, '',
          \ '| Mode | Shortcut | Action | Description | Example / when to use |',
          \ '|---|---|---|---|---|'])
    for l:e in filter(copy(g:my_keys), 'v:val.cat ==# l:cat && v:val.wk !=# "which_key_ignore"')
      let [l:info, l:ex] = my#keys#docs(l:e)
      let l:notes = []
      if !empty(l:e.scope) | call add(l:notes, '_' . l:e.scope . '_') | endif
      if !empty(l:e.cond)  | call add(l:notes, '_needs ' . l:e.cond . '_') | endif
      let l:desc = s:cell(l:info) . (empty(l:notes) ? '' : (empty(l:info) ? '' : ' ') . join(l:notes, ' · '))
      let l:key = '`' . escape(my#keys#pretty(l:e.lhs), '|') . '`'
      if l:e.lhs ==# '<leader>1' | let l:key .= ' … `<Space>9`' | endif
      call add(l:out, printf('| %s | %s | %s | %s | %s |',
            \ s:modes(l:e.modes), l:key, s:cell(empty(l:e.wk) ? l:e.desc : l:e.wk), l:desc, s:cell(l:ex)))
    endfor
  endfor
  return l:out
endfunction

" ── In-editor cheat sheet ─────────────────────────────────────────────────────
function! my#keys#cheatsheet_lines() abort
  let l:lines = ['All shortcuts — Leader is <Space>.  / searches · [n] Normal [x] Visual [i] Insert [t] Terminal [o] Operator', '']
  let l:cats = []
  for l:e in g:my_keys
    if index(l:cats, l:e.cat) < 0 | call add(l:cats, l:e.cat) | endif
  endfor
  for l:cat in l:cats
    call add(l:lines, '  ' . l:cat)
    for l:e in filter(copy(g:my_keys), 'v:val.cat ==# l:cat && v:val.wk !=# "which_key_ignore"')
      call add(l:lines, printf('    %-8s %-24s %s%s', '[' . l:e.modes . ']', my#keys#pretty(l:e.lhs), l:e.desc,
            \ empty(l:e.scope) ? '' : '  (' . l:e.scope . ')'))
    endfor
    call add(l:lines, '')
  endfor
  return l:lines
endfunction

function! my#keys#cheatsheet() abort
  let l:lines = my#keys#cheatsheet_lines()
  let l:lines[0] = '  Keyboard cheat sheet — Leader is <Space>.  Press q to close, / to search.'
  botright vnew
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nonumber norelativenumber
  setlocal signcolumn=no nolist nowrap filetype=mycheatsheet
  call setline(1, l:lines)
  setlocal nomodifiable
  execute 'vertical resize ' . min([&columns / 2, 96])
  nnoremap <buffer><silent><nowait> q :close <Bar> call my#find#main_window()<CR>
  syntax match CheatTitle /^  \S.*$/
  syntax match CheatKey /\%>13v<\S\+>\|\%13v\S\+/ contained
  syntax match CheatMode /^    \[\w\+\]/
  highlight default link CheatTitle Title
  highlight default link CheatMode Comment
endfunction
