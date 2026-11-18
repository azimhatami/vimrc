" ==============================================================================
"  my#edit — buffer management, whitespace, large files, small editing helpers
" ==============================================================================

function! my#edit#trim_whitespace() abort
  if &binary || !&modifiable | return | endif
  let l:view = winsaveview()
  keeppatterns silent! %s/\s\+$//e
  call winrestview(l:view)
endfunction

function! my#edit#mkdir_on_write(file) abort
  if a:file =~# '^\w\+://' | return | endif
  let l:dir = fnamemodify(a:file, ':p:h')
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif
endfunction

" Delete a buffer but keep the window layout (shows the alternate buffer).
function! my#edit#buf_delete(force) abort
  let l:buf = bufnr('%')
  if getbufvar(l:buf, '&modified') && !a:force
    echohl WarningMsg | echo 'Unsaved changes — save first or use <Space>bD to discard.' | echohl None
    return
  endif
  let l:listed = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != l:buf')
  for l:win in win_findbuf(l:buf)
    call win_execute(l:win, empty(l:listed) ? 'enew' : (buflisted(bufnr('#')) && bufnr('#') != l:buf ? 'buffer #' : 'bprevious'))
  endfor
  if bufexists(l:buf)
    execute (a:force ? 'bwipeout! ' : 'bdelete ') . l:buf
  endif
endfunction

" Close every listed buffer except the current one (unsaved ones are kept).
function! my#edit#buf_only() abort
  let l:cur = bufnr('%')
  let l:kept = 0
  for l:b in filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != l:cur')
    if getbufvar(l:b, '&modified')
      let l:kept += 1
    else
      execute 'silent bdelete ' . l:b
    endif
  endfor
  echo 'Closed other buffers' . (l:kept ? ' (kept ' . l:kept . ' with unsaved changes)' : '')
endfunction

" Large files: disable everything expensive before the file is read.
function! my#edit#large_file_check(file) abort
  let l:size = getfsize(a:file)
  if l:size < g:my_largefile_mb * 1024 * 1024 && l:size != -2
    return
  endif
  let b:my_large_file = 1
  let b:asyncomplete_enable = 0
  setlocal noundofile noswapfile bufhidden=unload foldmethod=manual nolist
  autocmd my_editing BufReadPost <buffer> ++once call my#edit#large_file_post()
endfunction

function! my#edit#large_file_post() abort
  setlocal syntax=OFF foldmethod=manual nolist
  if exists(':GitGutterBufferDisable') | silent! GitGutterBufferDisable | endif
  echohl WarningMsg
  echo printf('Large file (%.1f MB): lean mode — no syntax, LSP, git signs or undo file', getfsize(expand('%')) / 1048576.0)
  echohl None
endfunction

" Toggle an always-on-top zoom of the current window (like tmux prefix-z).
function! my#edit#zoom() abort
  if exists('t:my_zoom')
    execute t:my_zoom.restore
    unlet t:my_zoom
  else
    let t:my_zoom = {'restore': winrestcmd()}
    wincmd _ | wincmd |
  endif
endfunction

" Search for the visual selection literally with * / #.
function! my#edit#visual_search(dir) abort
  let l:save = [getreg('z'), getregtype('z')]
  normal! gv"zy
  let @/ = '\V' . substitute(escape(getreg('z'), a:dir . '\'), '\n', '\\n', 'g')
  call setreg('z', l:save[0], l:save[1])
  call histadd('/', @/)
  call feedkeys((a:dir ==# '/' ? 'n' : 'N'), 'n')
endfunction

" Prepare :%s for the word under the cursor (or the visual selection).
function! my#edit#substitute_prompt(visual) abort
  let l:text = a:visual ? my#find#selection() : expand('<cword>')
  let l:pat = a:visual ? '\V' . escape(l:text, '/\') : '\<' . escape(l:text, '/\') . '\>'
  return ':%s/' . l:pat . '/' . escape(l:text, '/\&~') . '/gc' . "\<Left>\<Left>\<Left>"
endfunction

" Add blank lines above/below without leaving normal mode (count-aware).
function! my#edit#blank_lines(below) abort
  let l:lines = repeat([''], v:count1)
  call append(line('.') - (a:below ? 0 : 1), l:lines)
  silent! call repeat#set(a:below ? "\<Plug>(my-blank-below)" : "\<Plug>(my-blank-above)", v:count1)
endfunction

" Quickfix / location list toggles
function! my#edit#toggle_list(loc) abort
  for l:w in getwininfo()
    if l:w.tabnr == tabpagenr() && (a:loc ? l:w.loclist : l:w.quickfix && !l:w.loclist)
      execute (a:loc ? 'lclose' : 'cclose')
      return
    endif
  endfor
  try
    execute (a:loc ? 'lopen' : 'copen')
  catch /E776/
    echo 'No location list for this window'
  endtry
endfunction
