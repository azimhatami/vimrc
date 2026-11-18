" ==============================================================================
"  my#git — small git helpers that fugitive/gitgutter don't provide
" ==============================================================================

" Pop-up with the commit that last touched the current line.
"   a1b2c3d · Jane Doe · 3 weeks ago
"   Fix race in session restore
function! my#git#blame_line() abort
  let l:file = expand('%:p')
  if empty(l:file) || !filereadable(l:file)
    echo 'Not a file on disk' | return
  endif
  let l:cmd = printf('git -C %s blame -L %d,%d --porcelain -- %s',
        \ shellescape(fnamemodify(l:file, ':h')), line('.'), line('.'), shellescape(l:file))
  let l:out = systemlist(l:cmd)
  if v:shell_error || empty(l:out)
    echo 'git blame: not tracked by git' | return
  endif
  let l:info = {'sha': l:out[0][:7]}
  for l:line in l:out[1:]
    let l:m = matchlist(l:line, '^\(author\|author-time\|summary\) \(.*\)$')
    if !empty(l:m) | let l:info[l:m[1]] = l:m[2] | endif
  endfor
  if l:info.sha =~# '^0\+$'
    let l:text = ['Not committed yet']
  else
    let l:text = [printf('%s · %s · %s', l:info.sha, get(l:info, 'author', '?'),
          \ s:ago(str2nr(get(l:info, 'author-time', 0)))), get(l:info, 'summary', '')]
  endif
  call popup_atcursor(l:text, {
        \ 'border': [1, 1, 1, 1], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'borderhighlight': ['FloatBorder'], 'highlight': 'Pmenu', 'padding': [0, 1, 0, 1],
        \ 'moved': 'any', 'title': ' blame '})
endfunction

function! s:ago(ts) abort
  let l:d = localtime() - a:ts
  for [l:n, l:unit] in [[31536000, 'year'], [2592000, 'month'], [604800, 'week'], [86400, 'day'], [3600, 'hour'], [60, 'minute']]
    if l:d >= l:n
      let l:v = l:d / l:n
      return l:v . ' ' . l:unit . (l:v > 1 ? 's' : '') . ' ago'
    endif
  endfor
  return 'just now'
endfunction
