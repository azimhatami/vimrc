" ==============================================================================
"  my#clip — system clipboard without +clipboard
"  Order: native "+ register → wl-copy (Wayland) → xclip/xsel (X11/XWayland)
"         → OSC 52 escape (SSH sessions; terminal permitting)
" ==============================================================================

function! my#clip#provider() abort
  if has('clipboard') | return 'native' | endif
  if !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste') | return 'wl' | endif
  if !empty($DISPLAY) && executable('xclip') | return 'xclip' | endif
  if !empty($DISPLAY) && executable('xsel')  | return 'xsel'  | endif
  if !empty($SSH_TTY) || !empty($SSH_CONNECTION) | return 'osc52' | endif
  return ''
endfunction

function! s:copy_cmd(p) abort
  return {'wl': ['wl-copy', '--type', 'text/plain'],
        \ 'xclip': ['xclip', '-quiet', '-selection', 'clipboard', '-in'],
        \ 'xsel': ['xsel', '--clipboard', '--input']}[a:p]
endfunction

function! s:paste_cmd(p) abort
  return {'wl': 'wl-paste --no-newline',
        \ 'xclip': 'xclip -selection clipboard -out',
        \ 'xsel': 'xsel --clipboard --output'}[a:p]
endfunction

" Asynchronous copy: never blocks the editor.
function! my#clip#copy(text) abort
  let l:p = my#clip#provider()
  if l:p ==# 'native'
    let @+ = a:text
  elseif l:p ==# 'osc52'
    call echoraw("\e]52;c;" . s:base64(a:text) . "\x07")
  elseif !empty(l:p)
    let l:job = job_start(s:copy_cmd(l:p), {'in_io': 'pipe', 'out_io': 'null', 'err_io': 'null', 'stoponexit': ''})
    if job_status(l:job) ==# 'run'
      call ch_sendraw(l:job, a:text)
      call ch_close_in(l:job)
    endif
  endif
endfunction

function! my#clip#paste_text() abort
  let l:p = my#clip#provider()
  if l:p ==# 'native' | return getreg('+') | endif
  if l:p ==# 'osc52' || empty(l:p)
    echohl WarningMsg | echo 'Clipboard read unavailable here — use your terminal paste (Ctrl+Shift+V).' | echohl None
    return v:null
  endif
  return system(s:paste_cmd(l:p))
endfunction

" Put clipboard contents after (p) / before (P) the cursor via register z.
function! my#clip#paste(cmd) abort
  let l:text = my#clip#paste_text()
  if l:text is v:null | return | endif
  let l:save = [getreg('z'), getregtype('z')]
  call setreg('z', l:text, l:text =~# '\n$' ? 'V' : 'v')
  execute 'normal! "z' . a:cmd
  call setreg('z', l:save[0], l:save[1])
endfunction

" Copy the visual selection explicitly (works even with sync turned off).
function! my#clip#copy_selection() abort
  let l:save = [getreg('z'), getregtype('z')]
  normal! gv"zy
  call my#clip#copy(getreg('z'))
  call setreg('z', l:save[0], l:save[1])
  echo 'Copied to system clipboard'
endfunction

function! my#clip#copy_path(modifier) abort
  let l:path = expand('%' . a:modifier)
  call my#clip#copy(l:path)
  echo 'Copied: ' . l:path
endfunction

function! s:base64(text) abort
  let l:out = system('base64 -w0', a:text)
  return v:shell_error ? '' : l:out
endfunction
