" ==============================================================================
"  my#core — small helpers shared by every module
" ==============================================================================

" True when a vim-plug plugin is declared AND present on disk.
function! my#core#has(name) abort
  return exists('g:plugs') && has_key(g:plugs, a:name) && isdirectory(g:plugs[a:name].dir)
endfunction

" Queue a warning; shown after startup (never blocks Vim from starting).
function! my#core#warn(msg) abort
  call add(g:my_errors, a:msg)
endfunction

function! my#core#report_errors() abort
  if empty(g:my_errors)
    return
  endif
  echohl WarningMsg
  for l:e in g:my_errors
    echom '[config] ' . l:e
  endfor
  echohl None
endfunction

" Toggle a boolean option locally and echo its new state.
function! my#core#toggle(option) abort
  execute 'setlocal ' . a:option . '!'
  execute 'echo "' . a:option . ': " . (&l:' . a:option . ' ? "on" : "off")'
endfunction

" Toggle a global flag variable and echo it.
function! my#core#toggle_flag(var, label) abort
  let g:[a:var] = !get(g:, a:var, 0)
  echo a:label . ': ' . (g:[a:var] ? 'on' : 'off')
endfunction

" Run a shell command in a reusable bottom terminal split (keeps output).
function! my#core#run_in_term(cmd, ...) abort
  let l:rows = get(a:, 1, 14)
  " Reuse/close a previous run window so runs don't pile up.
  for l:w in range(1, winnr('$'))
    if getbufvar(winbufnr(l:w), 'my_run_term', 0)
      execute l:w . 'close!'
      break
    endif
  endfor
  let g:my_last_run = a:cmd
  execute 'botright ' . l:rows . 'new'
  call term_start([&shell, &shellcmdflag, a:cmd], {
        \ 'curwin': 1,
        \ 'term_name': 'run: ' . a:cmd,
        \ 'term_finish': 'open',
        \ })
  let b:my_run_term = 1
  setlocal nobuflisted
  wincmd p
endfunction
