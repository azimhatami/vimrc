" ==============================================================================
"  my#term — a single, toggleable terminal panel at the bottom
" ==============================================================================

function! my#term#toggle() abort
  " Visible? → hide it (the shell keeps running).
  for l:w in range(1, winnr('$'))
    if getbufvar(winbufnr(l:w), 'my_panel_term', 0)
      execute l:w . 'hide'
      return
    endif
  endfor
  let l:height = max([10, &lines / 3])
  if exists('s:buf') && bufexists(s:buf) && term_getstatus(s:buf) =~# 'running'
    execute 'botright sbuffer ' . s:buf
    execute 'resize ' . l:height
  else
    execute 'botright ' . l:height . 'new'
    let s:buf = term_start(&shell, {'curwin': 1, 'term_name': 'terminal', 'term_finish': 'close'})
    call setbufvar(s:buf, 'my_panel_term', 1)
    setlocal nobuflisted winfixheight
    " <Esc><Esc> leaves terminal mode here (single <Esc> still reaches the shell).
    tnoremap <buffer><silent> <Esc><Esc> <C-\><C-n>
  endif
endfunction

" ── Floating terminal (Space tF / F12) — Vim's native pop-up terminal ─────────
" One persistent shell in a centred pop-up; hiding it keeps the shell (and
" anything running in it) alive. About 30 lines instead of a plugin.
" Inside: F12 hides it, <C-w>N (or <Esc><Esc>) = Normal mode to scroll/copy.
function! my#term#float() abort
  if exists('s:float_win') && !empty(popup_getpos(s:float_win))
    call popup_close(s:float_win)
    unlet s:float_win
    return
  endif
  if !exists('s:float_buf') || !bufexists(s:float_buf) || term_getstatus(s:float_buf) !~# 'running'
    let s:float_buf = term_start(&shell, {'hidden': 1, 'term_finish': 'close',
          \ 'term_kill': 'hup', 'term_name': 'floating terminal', 'norestore': 1})
    call setbufvar(s:float_buf, '&buflisted', 0)
    call setbufvar(s:float_buf, 'my_float_term', 1)
    call win_execute(bufwinid(s:float_buf), 'tnoremap <buffer><silent> <Esc><Esc> <C-\><C-n>')
  endif
  let l:w = max([60, float2nr(&columns * 0.84)])
  let l:h = max([12, float2nr(&lines * 0.72)])
  let s:float_win = popup_create(s:float_buf, {
        \ 'minwidth': l:w, 'maxwidth': l:w, 'minheight': l:h, 'maxheight': l:h,
        \ 'border': [], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'borderhighlight': ['FloatBorder'], 'highlight': 'MyFloatTerm',
        \ 'title': ' ' . fnamemodify(getcwd(), ':~') . ' ', 'padding': [0, 1, 0, 1],
        \ 'zindex': 150, 'mapping': 1 })
  " Buffer-local maps must be defined while the terminal buffer is current.
  call win_execute(s:float_win, 'tnoremap <buffer><silent> <Esc><Esc> <C-\><C-n>')
endfunction
