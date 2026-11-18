" ==============================================================================
"  my#run — run / test / build helpers (pytest, coverage, make, Cython
"  build_ext) that share one reusable terminal split
" ==============================================================================

function! s:save() abort
  if &modified && !empty(expand('%')) | silent write | endif
endfunction

" ── Python interpreter: the project's virtualenv when there is one ───────────
" Looks upward from the file (then the cwd) for .venv/ venv/ env/, then
" $VIRTUAL_ENV, then python3. Used by the runners below and by pyright.
function! my#run#python(...) abort
  let l:start = a:0 ? a:1 : expand('%:p:h')
  for l:base in uniq([l:start, getcwd()])
    if empty(l:base) | continue | endif
    for l:name in ['.venv', 'venv', 'env']
      let l:dir = finddir(l:name, fnameescape(l:base) . ';')
      if !empty(l:dir) && executable(fnamemodify(l:dir, ':p') . 'bin/python')
        return fnamemodify(l:dir, ':p') . 'bin/python'
      endif
    endfor
  endfor
  if !empty($VIRTUAL_ENV) && executable($VIRTUAL_ENV . '/bin/python')
    return $VIRTUAL_ENV . '/bin/python'
  endif
  return 'python3'
endfunction

" `python -m pytest` with the project interpreter (works without a global
" pytest on PATH, and always tests against the venv's packages).
function! s:pytest() abort
  let l:py = my#run#python()
  return (l:py ==# 'python3' ? 'python3' : shellescape(fnamemodify(l:py, ':~:.'))) . ' -m pytest'
endfunction

" Run the current file with the obvious interpreter.
function! my#run#file() abort
  call s:save()
  let l:f = shellescape(expand('%'))
  let l:runners = {
        \ 'python': shellescape(my#run#python()) . ' ' . l:f, 'sh': 'bash ' . l:f, 'bash': 'bash ' . l:f,
        \ 'javascript': 'node ' . l:f, 'typescript': (executable('tsx') ? 'tsx ' : 'npx --yes tsx ') . l:f,
        \ 'cpp': 'g++ -Wall -g ' . l:f . ' -o /tmp/vimrun && /tmp/vimrun',
        \ 'go': 'go run ' . l:f, 'c': 'gcc -Wall -g ' . l:f . ' -o /tmp/vimrun && /tmp/vimrun',
        \ 'vim': '' }
  if &filetype ==# 'vim'
    source % | echo 'Sourced ' . expand('%') | return
  endif
  let l:cmd = get(l:runners, &filetype, '')
  if empty(l:cmd)
    echo 'No runner for filetype "' . &filetype . '"' | return
  endif
  call my#core#run_in_term(l:cmd)
endfunction

" pytest the test function under the cursor (walks up to the enclosing
" `def test_*`, includes the class if any). Port of PyTestCurrentScope().
function! my#run#pytest_scope() abort
  call s:save()
  let l:lnum = line('.')
  let l:func = ''
  let l:class = ''
  while l:lnum > 0
    let l:text = getline(l:lnum)
    if empty(l:func)
      let l:m = matchlist(l:text, '^\s*\%(async\s\+\)\?def\s\+\(test\w*\)\s*(')
      if !empty(l:m) | let l:func = l:m[1] | let l:indent = indent(l:lnum) | endif
    elseif indent(l:lnum) < l:indent
      let l:m = matchlist(l:text, '^\s*class\s\+\(\w\+\)')
      if !empty(l:m) | let l:class = l:m[1] | break | endif
    endif
    let l:lnum -= 1
  endwhile
  if empty(l:func)
    echo 'No test function above the cursor' | return
  endif
  let l:node = expand('%') . (empty(l:class) ? '' : '::' . l:class) . '::' . l:func
  call my#core#run_in_term(s:pytest() . ' -vv ' . shellescape(l:node))
endfunction

function! my#run#pytest_file() abort
  call s:save()
  call my#core#run_in_term(s:pytest() . ' -vvv ' . shellescape(expand('%')))
endfunction

" Coverage for the project package (P = basename of cwd), as in your F7.
function! my#run#pytest_cov(file_only) abort
  call s:save()
  let l:pkg = fnamemodify(getcwd(), ':t')
  call my#core#run_in_term(s:pytest() . ' --cov=' . shellescape(l:pkg) . ' ' . (a:file_only ? shellescape(expand('%')) : 'tests'))
endfunction

" :make → quickfix (errors are jumpable with ]q / [q).
function! my#run#make(...) abort
  call s:save()
  execute 'make! ' . join(a:000, ' ')
  if !empty(getqflist()) && len(filter(getqflist(), 'v:val.valid'))
    copen
  else
    cclose | echo 'make: OK'
  endif
endfunction

function! my#run#make_flash() abort
  " Never run by accident: it writes to hardware.
  if confirm('Run `make flash`?', "&Yes\n&No", 2) != 1 | return | endif
  call s:save()
  call my#core#run_in_term('make flash')
endfunction

function! my#run#build_ext() abort
  call s:save()
  call my#core#run_in_term(shellescape(my#run#python()) . ' setup.py build_ext --force --inplace --define=CYTHON_TRACE')
endfunction

" pytest for the whole project (Space r T).
function! my#run#pytest_all() abort
  call s:save()
  call my#core#run_in_term(s:pytest() . ' -q')
endfunction

" Re-run the last runner command (Space r l).
function! my#run#last() abort
  if empty(get(g:, 'my_last_run', ''))
    echo 'Nothing has been run yet' | return
  endif
  call s:save()
  call my#core#run_in_term(g:my_last_run)
endfunction

" Pick a Makefile target (Space r k). Targets are read from the Makefile, never
" run automatically; flash/deploy/install-like targets ask for confirmation.
function! my#run#make_target() abort
  let l:mk = findfile('Makefile', '.;')
  if empty(l:mk) | let l:mk = findfile('makefile', '.;') | endif
  if empty(l:mk) | echo 'No Makefile above ' . getcwd() | return | endif
  let l:targets = my#run#make_targets(l:mk)
  if empty(l:targets) | echo 'No targets found in ' . l:mk | return | endif
  let l:dir = fnamemodify(l:mk, ':p:h')
  let l:Run = {t -> s:make_run(l:dir, t)}
  if get(g:, 'my_has_fzf', 0)
    call fzf#run(fzf#wrap({'source': l:targets, 'sink': l:Run,
          \ 'options': ['--prompt', 'make ❯ ', '--no-multi']}))
  else
    let l:i = inputlist(['make target:'] + map(copy(l:targets), '(v:key + 1) . ". " . v:val'))
    if l:i > 0 && l:i <= len(l:targets) | call l:Run(l:targets[l:i - 1]) | endif
  endif
endfunction

" Explicit targets of a Makefile (no pattern rules, variables or .SPECIAL ones).
function! my#run#make_targets(file) abort
  let l:t = map(readfile(a:file), 'matchstr(v:val, ''^\zs[A-Za-z0-9_.-]\+\ze\s*::\=\%([^=]\|$\)'')')
  return uniq(sort(filter(l:t, '!empty(v:val) && v:val !~# ''^\.''')))
endfunction

function! s:make_run(dir, target) abort
  if a:target =~? 'flash\|deploy\|install\|upload\|burn\|erase\|release\|publish'
        \ && confirm('Run `make ' . a:target . '`? (it may write to hardware or the system)', "&Yes\n&No", 2) != 1
    return
  endif
  call s:save()
  call my#core#run_in_term('make -C ' . shellescape(a:dir) . ' ' . shellescape(a:target))
endfunction

" Prettier opt-in check: a prettier config somewhere up the tree.
function! my#run#has_prettier_config() abort
  if exists('b:my_prettier_cfg') | return b:my_prettier_cfg | endif
  let l:names = ['.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml',
        \ '.prettierrc.json5', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.mjs',
        \ '.prettierrc.toml', 'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs']
  let l:dir = expand('%:p:h')
  let b:my_prettier_cfg = 0
  for l:n in l:names
    if !empty(findfile(l:n, l:dir . ';'))
      let b:my_prettier_cfg = 1 | break
    endif
  endfor
  if !b:my_prettier_cfg
    let l:pkg = findfile('package.json', l:dir . ';')
    if !empty(l:pkg) && match(readfile(l:pkg), '"prettier"\s*:\s*[{"]') >= 0
      let b:my_prettier_cfg = 1
    endif
  endif
  return b:my_prettier_cfg
endfunction
