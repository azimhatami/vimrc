" ==============================================================================
"  my#find — fzf helpers + graceful fallbacks when fzf / ripgrep are missing
" ==============================================================================

function! s:git_root() abort
  let l:root = exists('*FugitiveWorkTree') ? FugitiveWorkTree() : ''
  if empty(l:root) && executable('git')
    let l:root = trim(system('git -C ' . shellescape(getcwd()) . ' rev-parse --show-toplevel 2>/dev/null'))
    if v:shell_error | let l:root = '' | endif
  endif
  return l:root
endfunction

" Before opening a file from a picker: if the cursor is in the explorer, a
" list, a terminal or another tool window, move to a normal editing window.
function! s:is_tool(win) abort
  let l:b = winbufnr(a:win)
  return getbufvar(l:b, '&filetype') =~# '^\%(fern\|qf\|fugitive\|undotree\|diff\|mycheatsheet\|myguide\|myhealth\|vista\|vista_kind\)$'
        \ || getbufvar(l:b, '&buftype') =~# 'terminal\|quickfix\|prompt\|popup'
        \ || getwinvar(a:win, '&previewwindow')
endfunction

function! my#find#main_window() abort
  if !s:is_tool(winnr()) | return | endif
  if !s:is_tool(winnr('#')) && winnr('#') > 0
    wincmd p | return
  endif
  for l:w in range(1, winnr('$'))
    if !s:is_tool(l:w)
      execute l:w . 'wincmd w' | return
    endif
  endfor
  " Only tool windows: open a fresh split for the file.
  botright vnew
endfunction

" Git repo → tracked + untracked (not ignored) files; elsewhere → all files.
function! my#find#project_files(bang) abort
  if !empty(s:git_root())
    call fzf#vim#gitfiles('--cached --others --exclude-standard', fzf#vim#with_preview(), a:bang)
  else
    call fzf#vim#files('', fzf#vim#with_preview(), a:bang)
  endif
endfunction

" Grep an exact word (or the given text) across the project.
function! my#find#grep_word(text, bang) abort
  let l:q = empty(a:text) ? expand('<cword>') : a:text
  if empty(l:q) | return | endif
  if executable('rg')
    let l:cmd = 'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git" '
          \ . (empty(a:text) ? '--word-regexp ' : '') . '--fixed-strings -- ' . shellescape(l:q)
  else
    let l:cmd = 'git grep --line-number --column --color=always -F ' . (empty(a:text) ? '-w ' : '') . '-- ' . shellescape(l:q)
  endif
  call fzf#vim#grep(l:cmd, fzf#vim#with_preview(), a:bang)
endfunction

" Text of the last visual selection (single line).
function! my#find#selection() abort
  let [l:s, l:e] = [getpos("'<"), getpos("'>")]
  let l:lines = getline(l:s[1], l:e[1])
  if empty(l:lines) | return '' | endif
  let l:lines[-1] = l:lines[-1][: l:e[2] - (&selection ==# 'inclusive' ? 1 : 2)]
  let l:lines[0]  = l:lines[0][l:s[2] - 1 :]
  return join(l:lines, "\n")
endfunction

" fzf action: send marked lines to the quickfix list (then :cdo / :cfdo).
function! my#find#to_quickfix(lines) abort
  call setqflist(map(copy(a:lines), '{"filename": v:val, "lnum": 1}'))
  copen
  cc
endfunction

" ── Fallbacks (no fzf) ────────────────────────────────────────────────────────
function! my#find#fallback_files() abort
  call feedkeys(':find ', 'n')
endfunction

function! my#find#fallback_grep(...) abort
  let l:q = a:0 ? a:1 : input('Grep › ')
  if empty(l:q) | return | endif
  execute 'silent grep! ' . shellescape(l:q)
  copen
  redraw!
endfunction

function! my#find#fallback_buffers() abort
  ls
  call feedkeys(':buffer ', 'n')
endfunction
