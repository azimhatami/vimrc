" ==============================================================================
"  my#dashboard — start screen content and startup logic (see dashboard.vim)
" ==============================================================================

" Section icons (Nerd Font codepoints as escapes; plain symbols otherwise):
"   folder-open U+F07C · history U+F1DA · project U+F503 · session U+F0C7
"   terminal U+F120 · branch U+E0A0 · bolt U+F0E7 · plug U+F1E6
let s:i = get(g:, 'my_icons', 0)
let s:sym = {
      \ 'folder':  s:i ? "  " : '▸ ',
      \ 'history': s:i ? "  " : '▸ ',
      \ 'project': s:i ? "  " : '▸ ',
      \ 'session': s:i ? "  " : '▸ ',
      \ 'command': s:i ? "  " : '▸ ',
      \ 'branch':  s:i ? " " : '⎇ ',
      \ 'bolt':    s:i ? " " : '',
      \ 'plug':    s:i ? " " : '' }

function! my#dashboard#section(name) abort
  return get(s:sym, a:name, '')
endfunction

" ── Startup ───────────────────────────────────────────────────────────────────
" Why the dashboard should NOT open ('' = open it). Inspect with
"   :echo g:my_dashboard_skipped
function! my#dashboard#skip_reason() abort
  if !get(g:, 'my_dashboard', 1)               | return 'disabled (g:my_dashboard = 0)' | endif
  if !get(g:, 'my_has_dashboard', 0)           | return 'vim-startify is not installed' | endif
  if mode(1) !=# 'n'                           | return 'Ex/batch mode' | endif
  if !has('gui_running') && (!has('ttyin') || !has('ttyout'))
    return 'input or output is not a terminal'
  endif
  if get(g:, 'my_stdin', 0)                    | return 'reading stdin (vim -)' | endif
  if argc() > 0                                | return 'files or directories given on the command line' | endif
  if !empty(v:this_session)                    | return 'a session was loaded (vim -S)' | endif
  " -c/+cmd, -q (quickfix), -t (tag), -d (diff), -S/-s (session/script),
  " -e/-E/-b/-y… mean you asked for something else. Harmless flags such as
  " -N, -n, -u vimrc, --cmd …, --startuptime f are fine.
  for l:a in v:argv[1:]
    if l:a ==# '--' | break | endif
    if l:a =~# '^+\|^--remote\|^--not-a-term' || (l:a =~# '^-[a-zA-Z]\+$' && l:a =~# '[cqtdSseEby]')
      return 'startup flag ' . l:a
    endif
  endfor
  if &diff                                     | return 'diff mode' | endif
  if line2byte('$') != -1 || !empty(bufname('%')) || &buftype !=# ''
    return 'the editor window is not empty'
  endif
  return ''
endfunction

" VimEnter (before the explorer): put the dashboard in the editor window.
function! my#dashboard#autostart() abort
  let g:my_startup_ms = float2nr(reltimefloat(reltime(get(g:, 'my_start_time', reltime()))) * 1000)
  let g:my_dashboard_skipped = my#dashboard#skip_reason()
  if empty(g:my_dashboard_skipped)
    Startify
  endif
endfunction

" ── Buffer setup (User Startified) ────────────────────────────────────────────
function! my#dashboard#setup() abort
  setlocal nocursorline nolist colorcolumn= signcolumn=no nonumber norelativenumber
  let b:asyncomplete_enable = 0
  " Keep the cursor on the first entry instead of the header.
  call search('^\s*\[', 'cw')
endfunction

" ── Header / footer ───────────────────────────────────────────────────────────
let s:logo = [
      \ '██╗   ██╗██╗███╗   ███╗',
      \ '██║   ██║██║████╗ ████║',
      \ '██║   ██║██║██╔████╔██║',
      \ '╚██╗ ██╔╝██║██║╚██╔╝██║',
      \ ' ╚████╔╝ ██║██║ ╚═╝ ██║',
      \ '  ╚═══╝  ╚═╝╚═╝     ╚═╝' ]

function! my#dashboard#header() abort
  let l:pad = '    '
  let l:ver = printf('Vim %d.%d', v:version / 100, v:version % 100)
  let l:info = [l:ver, my#ui#theme_name(), len(get(g:, 'plugs', {})) . ' plugins']
  if exists('g:my_startup_ms')
    call add(l:info, s:sym.bolt . 'ready in ' . g:my_startup_ms . ' ms')
  endif
  let l:proj = fnamemodify(getcwd(), ':~')
  let l:head = exists('*FugitiveHead') ? FugitiveHead(7, getcwd()) : ''
  if empty(l:head) && exists('*FugitiveExtractGitDir') && !empty(FugitiveExtractGitDir(getcwd()))
    let l:head = '(detached)'
  endif
  return [''] + map(copy(s:logo), 'l:pad . v:val') + ['',
        \ l:pad . join(l:info, '  ·  '),
        \ l:pad . l:proj . (empty(l:head) ? '' : '   ' . s:sym.branch . l:head), '']
endfunction

function! my#dashboard#footer() abort
  return ['', '    Space Space files · Space / grep · Space e explorer · Space g g git · Space l o outline',
        \ '    Space t F floating terminal · Space h c help & shortcuts · e empty buffer · q quit']
endfunction

" ── Recent files: one cheap pass over v:oldfiles feeds both lists ─────────────
" (Startify's own 'dir'/'files' lists resolve() and stat every one of the 300
" remembered files on each render; here the path prefix is checked first and
" only the few candidates that will be shown touch the filesystem.)
function! s:skipped(path) abort
  return !empty(filter(copy(get(g:, 'startify_skiplist', [])), 'a:path =~# v:val'))
endfunction

function! s:scan() abort
  let l:key = getcwd() . '|' . len(v:oldfiles) . '|' . get(v:oldfiles, 0, '')
  if get(s:, 'scan_key', '') ==# l:key && reltimefloat(reltime(s:scan_time)) < 2.0
    return s:scan_result
  endif
  let l:max = get(g:, 'startify_files_number', 6)
  let l:cwd = fnamemodify(getcwd(), ':p')
  let l:icons = get(g:, 'my_icons', 0) && my#core#has('vim-nerdfont')
  let [l:here, l:else, l:seen] = [[], [], {}]
  for l:f in v:oldfiles
    if len(l:here) >= l:max && len(l:else) >= l:max | break | endif
    let l:p = fnamemodify(l:f, ':p')
    if has_key(l:seen, l:p) || l:p =~# '^\a\+://' | continue | endif
    let l:seen[l:p] = 1
    let l:inside = stridx(l:p, l:cwd) == 0
    let l:list = l:inside ? l:here : l:else
    if len(l:list) >= l:max || s:skipped(l:p) || !filereadable(l:p) | continue | endif
    let l:shown = l:inside ? l:p[len(l:cwd):] : fnamemodify(l:p, ':~')
    call add(l:list, {'line': (l:icons ? nerdfont#find(l:p) . '  ' : '') . l:shown, 'path': l:p})
  endfor
  let [s:scan_key, s:scan_time, s:scan_result] = [l:key, reltime(), [l:here, l:else]]
  return s:scan_result
endfunction

" Recently edited files of this project (the directory Vim started in).
function! my#dashboard#project_recent() abort
  return s:scan()[0]
endfunction

" Recently edited files everywhere else.
function! my#dashboard#recent() abort
  return s:scan()[1]
endfunction

" ── Projects: git roots of recently edited files ─────────────────────────────
function! s:git_root(dir, cache) abort
  if has_key(a:cache, a:dir) | return a:cache[a:dir] | endif
  let l:git = finddir('.git', fnameescape(a:dir) . ';')
  if empty(l:git) | let l:git = findfile('.git', fnameescape(a:dir) . ';') | endif
  let l:root = empty(l:git) ? '' : fnamemodify(l:git, ':p:h:h')
  let l:root = substitute(l:root, '/\.git$', '', '')
  let a:cache[a:dir] = l:root
  return l:root
endfunction

function! my#dashboard#project_list(...) abort
  let l:max = a:0 ? a:1 : 5
  let l:cwd = fnamemodify(getcwd(), ':p:h')
  let l:home = fnamemodify(expand('~'), ':p:h')
  let [l:seen, l:cache, l:out] = [{}, {}, []]
  " Only the most recent entries: keeps this cheap (a few stat calls each).
  for l:f in v:oldfiles[:49]
    let l:f = expand(l:f)
    if l:f =~# '^\a\+://\|^/tmp/\|/\.git/' | continue | endif
    let l:dir = fnamemodify(l:f, ':p:h')
    if !isdirectory(l:dir) | continue | endif
    let l:root = s:git_root(l:dir, l:cache)
    if empty(l:root) || l:root ==# l:home || l:root ==# l:cwd || has_key(l:seen, l:root)
      continue
    endif
    let l:seen[l:root] = 1
    call add(l:out, l:root)
    if len(l:out) >= l:max | break | endif
  endfor
  return l:out
endfunction

function! my#dashboard#projects() abort
  return map(my#dashboard#project_list(5), {_, r -> {
        \ 'line': fnamemodify(r, ':t') . repeat(' ', max([1, 24 - strchars(fnamemodify(r, ':t'))])) . fnamemodify(r, ':~'),
        \ 'cmd': 'call my#dashboard#open_project(' . string(r) . ')'}})
endfunction

" Switch to another project: cd, re-root the explorer, refresh the dashboard.
function! my#dashboard#open_project(root) abort
  execute 'cd' fnameescape(a:root)
  if get(g:, 'my_has_fern', 0) && my#fern#drawer_winnr()
    let l:w = my#fern#drawer_winnr()
    execute l:w . 'close'
    call my#fern#open_sidebar(getcwd(), 1)
  endif
  Startify
  echo 'Project: ' . fnamemodify(a:root, ':~')
endfunction

" ── Sessions saved with <Space>qs (one per directory) ─────────────────────────
function! my#dashboard#sessions() abort
  let l:files = glob(g:my_state_dir . '/sessions/*.vim', 0, 1)
  call sort(l:files, {a, b -> getftime(b) - getftime(a)})
  return map(l:files[:3], {_, f -> {
        \ 'line': my#session#label(f)
        \         . '   ' . strftime('%Y-%m-%d %H:%M', getftime(f)),
        \ 'cmd': 'call my#session#load(' . string(f) . ')'}})
endfunction

" ── Commands ──────────────────────────────────────────────────────────────────
" Fuzzy pickers need fzf; fall back gracefully when it is missing.
function! my#dashboard#run(cmd) abort
  if exists(':' . a:cmd) == 2
    execute a:cmd
  else
    echohl WarningMsg | echo ':' . a:cmd . ' is not available (fzf missing?)' | echohl None
  endif
endfunction

function! my#dashboard#config() abort
  edit ~/.vim/vimrc
  if get(g:, 'my_has_fern', 0) && my#fern#drawer_winnr()
    " Show the config directory in the explorer while you're there.
    execute my#fern#drawer_winnr() . 'close'
    call my#fern#open_sidebar(expand('~/.vim'), 1)
  endif
endfunction

function! my#dashboard#open() abort
  if get(g:, 'my_has_dashboard', 0)
    if my#fern#is_drawer() | wincmd p | endif
    Startify
  else
    echo 'Dashboard needs vim-startify'
  endif
endfunction
