" ==============================================================================
"  my#session — one session per working directory, stored in ~/.vim/state
" ==============================================================================

" File name = the directory with / → +  (e.g. ~+workspace+app.vim). Names
" are free of % # and spaces, so `vim -S <file>` works without escaping.
" Sessions saved by the first version of this config used % instead of + —
" they are still found and loaded.
function! s:path(name) abort
  if !empty(a:name)
    return fnamemodify(a:name, ':p')
  endif
  let l:dir = fnamemodify(getcwd(), ':~')
  let l:file = g:my_state_dir . '/sessions/' . substitute(l:dir, '[/\\: %#]', '+', 'g') . '.vim'
  let l:legacy = g:my_state_dir . '/sessions/' . substitute(l:dir, '[/\\: ]', '%', 'g') . '.vim'
  return !filereadable(l:file) && filereadable(l:legacy) ? l:legacy : l:file
endfunction

" Readable directory name for a session file (dashboard list).
function! my#session#label(file) abort
  return substitute(fnamemodify(a:file, ':t:r'), '[+%]', '/', 'g')
endfunction

function! my#session#save(name) abort
  let l:file = s:path(a:name)
  " The explorer sidebar is reopened after saving (and on load, by SessionLoadPost).
  let l:had_sidebar = exists('*my#fern#drawer_winnr') && my#fern#drawer_winnr()
  if l:had_sidebar && my#fern#is_drawer() | wincmd p | endif
  " Drawer/tool windows don't restore cleanly — close them first.
  for l:w in reverse(range(1, winnr('$')))
    if getbufvar(winbufnr(l:w), '&filetype') =~# '^\%(fern\|undotree\|diff\|fugitive\|qf\)$' && winnr('$') > 1
      execute l:w . 'close'
    endif
  endfor
  execute 'mksession! ' . fnameescape(l:file)
  if l:had_sidebar | call my#fern#open_sidebar(getcwd(), 1) | endif
  echo 'Session saved → ' . fnamemodify(l:file, ':~')
endfunction

function! my#session#load(name) abort
  let l:file = s:path(a:name)
  if !filereadable(l:file)
    echohl WarningMsg | echo 'No session for ' . fnamemodify(getcwd(), ':~') . ' (save one with <Space>qs)' | echohl None
    return
  endif
  if len(filter(range(1, bufnr('$')), 'getbufvar(v:val, "&modified")'))
    echohl WarningMsg | echo 'Save your changes before loading a session.' | echohl None
    return
  endif
  silent! %bwipeout
  execute 'source ' . fnameescape(l:file)
  echo 'Session loaded ← ' . fnamemodify(l:file, ':~')
endfunction

function! my#session#delete() abort
  let l:file = s:path('')
  if !filereadable(l:file)
    echo 'No session for this directory' | return
  endif
  if confirm('Delete session ' . fnamemodify(l:file, ':~') . '?', "&Yes\n&No", 2) == 1
    call delete(l:file)
    echo 'Session deleted'
  endif
endfunction
