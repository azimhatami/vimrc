" ==============================================================================
"  my#fern — explorer drawer: buffer setup, curated keys, helpers
"  Keys inside the tree are registered with my#keys#doc() in mappings.vim.
" ==============================================================================

function! my#fern#setup() abort
  setlocal nonumber norelativenumber signcolumn=no nolist nofoldenable cursorline
  setlocal winfixwidth
  " vim -R / view marks every new buffer read-only; the tree is redrawn by
  " fern itself, which would then trip W10 "Changing a readonly file".
  setlocal noreadonly
  if exists('*glyph_palette#apply') | call glyph_palette#apply() | endif

  " Opening / navigating
  nmap <buffer><nowait> <CR>  <Plug>(fern-action-open-or-expand)
  nmap <buffer><nowait> l     <Plug>(fern-action-open-or-expand)
  nmap <buffer><nowait> o     <Plug>(fern-action-open-or-expand)
  nmap <buffer><nowait> h     <Plug>(fern-action-collapse)
  nmap <buffer><nowait> s     <Plug>(fern-action-open:split)
  nmap <buffer><nowait> v     <Plug>(fern-action-open:vsplit)
  nmap <buffer><nowait> t     <Plug>(fern-action-open:tabedit)
  nmap <buffer><nowait> <BS>  <Plug>(fern-action-leave)
  nmap <buffer><nowait> -     <Plug>(fern-action-leave)
  nmap <buffer><nowait> =     <Plug>(fern-action-enter)
  nmap <buffer><nowait> X     <Plug>(fern-action-open:system)
  " File operations (each one asks before touching disk)
  nmap <buffer><nowait> a     <Plug>(fern-action-new-path)
  nmap <buffer><nowait> r     <Plug>(fern-action-rename)
  nmap <buffer><nowait> c     <Plug>(fern-action-copy)
  nmap <buffer><nowait> m     <Plug>(fern-action-move)
  nmap <buffer><nowait> d     <Plug>(fern-action-trash)
  nmap <buffer><nowait> D     <Plug>(fern-action-remove)
  nmap <buffer><nowait> y     <Plug>(fern-action-yank:path)
  " Selection, view, misc
  nmap <buffer><nowait> x     <Plug>(fern-action-mark:toggle)j
  nmap <buffer><nowait> !     <Plug>(fern-action-hidden:toggle)
  nnoremap <buffer><silent><nowait> I :<C-u>call my#fern#toggle_exclude()<CR>
  nmap <buffer><nowait> R     <Plug>(fern-action-reload:all)
  nmap <buffer><nowait> gc    <Plug>(fern-action-tcd:cursor)
  nmap <buffer><nowait> ?     <Plug>(fern-action-help)
  nnoremap <buffer><silent><nowait> q :<C-u>call my#fern#close()<CR>
endfunction

" Toggle the ignore filter on/off (shows build/, dist/, …).
function! my#fern#toggle_exclude() abort
  let g:my_fern_exclude_on = !get(g:, 'my_fern_exclude_on', 1)
  let l:pat = g:my_fern_exclude_on ? g:my_fern_exclude : ''
  let l:helper = fern#helper#new()
  call l:helper.async.set_exclude(l:pat).then({ -> l:helper.async.redraw() })
  echo 'Explorer ignore filter: ' . (g:my_fern_exclude_on ? 'on' : 'off')
endfunction

" ══ Drawer helpers ═══════════════════════════════════════════════════════════

function! my#fern#is_drawer(...) abort
  let l:name = a:0 ? bufname(a:1) : bufname('%')
  return l:name =~# '^fern://drawer\%(-right\)\=:'
endfunction

" Window number of the left drawer in the current tab (0 = none).
function! my#fern#drawer_winnr() abort
  for l:w in range(1, winnr('$'))
    if my#fern#is_drawer(winbufnr(l:w)) | return l:w | endif
  endfor
  return 0
endfunction

" -reveal=… only for files inside the tree's root (fern can't reveal outside it).
function! s:reveal_arg(root) abort
  let l:file = expand('%:p')
  let l:root = substitute(fnamemodify(a:root, ':p'), '/\=$', '/', '')
  if empty(l:file) || !filereadable(l:file) || stridx(l:file, l:root) != 0 || &buftype !=# ''
    return ''
  endif
  return ' -reveal=' . fnameescape(l:file)
endfunction

" Open the sidebar on {root}. {stay}: keep the cursor in the current window.
" Never creates a second drawer in the same tab.
function! my#fern#open_sidebar(root, stay) abort
  let l:w = my#fern#drawer_winnr()
  if l:w
    if !a:stay | execute l:w . 'wincmd w' | endif
    return
  endif
  execute 'Fern' fnameescape(a:root) '-drawer -width=' . g:fern#drawer_width
        \ . (a:stay ? ' -stay' : '') . s:reveal_arg(a:root)
  " vim -R: Vim flags the new tree read-only once loaded (see navigation.vim).
  let l:w = my#fern#drawer_winnr()
  if l:w | call setbufvar(winbufnr(l:w), '&readonly', 0) | endif
endfunction

" <Space>e / <C-n>: open (cursor moves into the tree) or close.
function! my#fern#toggle() abort
  if my#fern#drawer_winnr()
    call my#fern#close()
  else
    call my#fern#open_sidebar(getcwd(), 0)
  endif
endfunction

" <Space>E: open/focus the drawer with the cursor on the current file.
function! my#fern#reveal() abort
  execute 'Fern . -drawer -width=' . g:fern#drawer_width . s:reveal_arg(getcwd())
endfunction

" Close the drawer. If it is the last window of the tab, an empty buffer
" takes its place instead (closing the explorer never quits Vim).
function! my#fern#close() abort
  let l:w = my#fern#drawer_winnr()
  if !l:w | return | endif
  if winnr('$') == 1
    enew
  else
    let l:back = my#fern#is_drawer() ? win_getid(winnr('#')) : win_getid()
    execute l:w . 'close'
    if win_id2win(l:back) | call win_gotoid(l:back) | endif
  endif
endfunction

" ══ Automatic sidebar at startup ══════════════════════════════════════════════
" g:my_explorer_autostart = 0 (in ~/.vim/local.vim, or vim --cmd '…') turns it off.

let s:special_ft = '^\%(gitcommit\|gitrebase\|gitsendemail\|hgcommit\|svn\|cvs\|bzr\|mail\|crontab\|sudoers\|man\|help\|vim-plug\|fugitive\|git\)$'

function! s:tmp_dirs() abort
  let l:dirs = []
  for l:d in [$TMPDIR, '/tmp', '/var/tmp', '/dev/shm', '/run/user']
    if !empty(l:d) && isdirectory(l:d)
      call add(l:dirs, substitute(resolve(fnamemodify(l:d, ':p')), '/\=$', '/', ''))
    endif
  endfor
  return l:dirs
endfunction

" Why the sidebar should NOT open now ('' = open it). Kept separate so it can
" be tested, and inspected with  :echo g:my_explorer_autostart_skipped
function! my#fern#skip_reason() abort
  if !get(g:, 'my_explorer_autostart', 1)        | return 'disabled (g:my_explorer_autostart = 0)' | endif
  if !get(g:, 'my_has_fern', 0)                  | return 'fern is not installed' | endif
  if mode(1) !=# 'n'                             | return 'Ex/batch mode (vim -e/-es/-Es)' | endif
  if !has('gui_running') && (!has('ttyin') || !has('ttyout'))
    return 'input or output is not a terminal'
  endif
  if get(g:, 'my_stdin', 0)                      | return 'reading stdin (vim -)' | endif
  " -d diff, -b binary, -y easy, -s scriptin, -e/-E Ex, -R… plus --not-a-term
  for l:a in v:argv[1:]
    if l:a ==# '--' | break | endif
    if l:a ==# '--not-a-term' || (l:a =~# '^-[a-zA-Z]\+$' && l:a =~# '[eEsdby]')
      return 'special startup flag ' . l:a
    endif
  endfor
  if &diff                                       | return 'diff mode' | endif
  if &columns < g:fern#drawer_width + 50         | return 'terminal narrower than ' . (g:fern#drawer_width + 50) . ' columns' | endif
  if &buftype !=# '' && &filetype !~# '^\%(fern\|startify\)$' | return 'special buffer (' . &buftype . ')' | endif
  if &filetype =~# s:special_ft                  | return 'special file type (' . &filetype . ')' | endif
  let l:cwd = substitute(resolve(getcwd()), '/\=$', '/', '')
  for l:f in argv()
    if l:f =~# '^\a[a-zA-Z0-9+.-]*://'          | return 'remote file ' . l:f | endif
    let l:p = resolve(fnamemodify(l:f, ':p'))
    if isdirectory(l:p) | continue | endif       " vim some/dir is always a project
    if l:p =~# '/\.git/'                        | return 'git internal file (commit message, rebase todo…)' | endif
    " crontab -e, sudoedit, Ctrl-X Ctrl-E in bash, kubectl edit, mutt… all
    " hand Vim a temp file outside the project you are in.
    for l:t in s:tmp_dirs()
      if stridx(l:p, l:t) == 0 && stridx(l:p, l:cwd) != 0
        return 'temporary file ' . l:f
      endif
    endfor
  endfor
  return ''
endfunction

" VimEnter: open the sidebar on the launch directory, cursor stays in the editor.
function! my#fern#autostart() abort
  let g:my_explorer_autostart_skipped = my#fern#skip_reason()
  if !empty(g:my_explorer_autostart_skipped) || my#fern#drawer_winnr()
    return
  endif
  let l:root = getcwd()
  " vim some/dir: that directory becomes the project (like NERDTree's old
  " `vim dir`): cd into it, tree on the left, empty editor on the right.
  if argc() == 1 && isdirectory(argv(0))
    let l:root = fnamemodify(argv(0), ':p')
    execute 'cd' fnameescape(l:root)
    if &filetype ==# 'fern'          " vim-fern-hijack already put a tree here
      let l:hijacked = bufnr('%')
      enew
      execute 'silent! bwipeout' l:hijacked
    endif
  endif
  call my#fern#open_sidebar(l:root, 1)
endfunction

" Restored sessions (vim -S, <Space>ql): bring the sidebar back in the current
" tab. At startup VimEnter handles it, after the session has been sourced.
" Sessions run `doautoall SessionLoadPost` (once per buffer, inside a temporary
" window), so the work is deferred to one timer once the layout has settled.
let s:session_pending = 0
function! my#fern#session_loaded() abort
  if v:vim_did_enter && !s:session_pending && get(g:, 'my_explorer_autostart', 1) && get(g:, 'my_has_fern', 0)
    let s:session_pending = 1
    call timer_start(0, {-> s:session_sidebar()})
  endif
endfunction

function! s:session_sidebar() abort
  let s:session_pending = 0
  if my#fern#is_drawer() | return | endif
  call my#fern#open_sidebar(getcwd(), 1)
endfunction

" ══ Quitting with a sidebar open ══════════════════════════════════════════════
" :q / :wq / ZZ in the last editing window of a tab closes that tab's drawer
" first, so Vim (or the tab) closes exactly as if there were no sidebar. Unlike
" the old NERDTree "quit if only the tree is left" hack, nothing ever quits Vim
" behind your back: :bd, :close or <C-w>c on the editor just leave the sidebar
" with a fresh empty editor beside it.

" Side panels that close together with the last editor: the explorer drawer,
" the symbol outline (Vista) and the undo tree (with its diff panel).
function! s:is_side_panel(buf) abort
  return my#fern#is_drawer(a:buf)
        \ || getbufvar(a:buf, '&filetype') =~# '^\%(vista\|vista_kind\|undotree\)$'
        \ || bufname(a:buf) =~# '^diffpanel_\d\+$'
endfunction

function! my#fern#quit_pre() abort
  if s:is_side_panel(bufnr('%')) | return | endif
  let l:drawers = []
  for l:w in range(1, winnr('$'))
    if l:w == winnr() | continue | endif
    if !s:is_side_panel(winbufnr(l:w)) | return | endif
    call add(l:drawers, win_getid(l:w))
  endfor
  if empty(l:drawers) | return | endif
  for l:id in l:drawers
    execute win_id2win(l:id) . 'close'
  endfor
  " Quit refused (E37 unsaved changes, E173 more files to edit…)? Then the
  " window is still here: put the sidebar back.
  let l:win = win_getid()
  call timer_start(0, {-> s:after_quit(l:win)})
endfunction

function! s:after_quit(win) abort
  if win_id2win(a:win) && !my#fern#drawer_winnr()
    call my#fern#open_sidebar(getcwd(), 1)
  endif
endfunction

" A tab left with nothing but the sidebar gets an empty editor on the right.
function! my#fern#after_win_closed() abort
  if winnr('$') == 1 && my#fern#is_drawer()
    let l:drawer = win_getid()
    botright vnew
    call win_execute(l:drawer, 'vertical resize ' . g:fern#drawer_width)
  endif
endfunction
