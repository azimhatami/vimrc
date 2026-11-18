" ==============================================================================
"  lightline colour scheme generated from the shared palette (my#ui#palette):
"  Space Vim Dark, Catppuccin Mocha or Latte — whichever theme is active, so
"  <Space>tb / <Space>tB restyle the status line and buffer line together
"  with the editor. Mode colours come from the palette's mode_* roles.
"
"  Layout:   ( MODE )  branch +2 ~1   path/to/file.py ●  ……  ✘ 2 ▲ 1  pyright   python   12:5 ( 42% )
" ==============================================================================

let s:c = my#ui#palette()
function! s:col(fg, bg, ...) abort
  let l:attr = a:0 ? a:1 : ''
  " lightline wants cterm numbers too; cheap placeholders when in true colour.
  let l:entry = &termguicolors ? [a:fg, a:bg, 'NONE', 'NONE'] : [a:fg, a:bg, my#ui#to256(a:fg), my#ui#to256(a:bg)]
  return empty(l:attr) ? l:entry : l:entry + [l:attr]
endfunction

let s:mid    = get(g:, 'my_transparent', 0) ? s:c.base : s:c.mantle
let s:accent = {
      \ 'normal':   get(s:c, 'mode_normal', s:c.blue),     'insert':   get(s:c, 'mode_insert', s:c.green),
      \ 'visual':   get(s:c, 'mode_visual', s:c.mauve),    'replace':  get(s:c, 'mode_replace', s:c.red),
      \ 'command':  get(s:c, 'mode_command', s:c.peach),   'terminal': get(s:c, 'mode_terminal', s:c.teal),
      \ 'select':   get(s:c, 'mode_select', s:c.pink) }

let s:p = {'inactive': {}, 'tabline': {}}
for [s:mode, s:acc] in items(s:accent)
  let s:p[s:mode] = {
        \ 'left':    [ s:col(s:c.crust, s:acc, 'bold'),
        \              s:col(s:c.text, s:c.surface0),
        \              s:col(s:c.subtext1, s:mid) ],
        \ 'middle':  [ s:col(s:c.overlay1, s:mid) ],
        \ 'right':   [ s:col(s:c.crust, s:acc, 'bold'),
        \              s:col(s:c.text, s:c.surface0),
        \              s:col(s:c.overlay2, s:mid) ],
        \ 'error':   [ s:col(s:c.red, s:mid, 'bold') ],
        \ 'warning': [ s:col(s:c.yellow, s:mid, 'bold') ],
        \ 'info':    [ s:col(s:c.sky, s:mid) ],
        \ 'lsp':     [ s:col(s:c.teal, s:mid) ],
        \ }
endfor

let s:p.inactive = {
      \ 'left':    [ s:col(s:c.overlay0, s:mid), s:col(s:c.overlay0, s:mid), s:col(s:c.overlay0, s:mid) ],
      \ 'middle':  [ s:col(s:c.overlay0, s:mid) ],
      \ 'right':   [ s:col(s:c.overlay0, s:mid), s:col(s:c.overlay0, s:mid), s:col(s:c.overlay0, s:mid) ],
      \ 'error':   [ s:col(s:c.overlay0, s:mid) ],
      \ 'warning': [ s:col(s:c.overlay0, s:mid) ],
      \ 'info':    [ s:col(s:c.overlay0, s:mid) ],
      \ 'lsp':     [ s:col(s:c.overlay0, s:mid) ],
      \ }

" Buffer line: quiet tabs, the current buffer lifted with a lavender label.
let s:p.tabline = {
      \ 'left':    [ s:col(s:c.overlay1, s:c.mantle) ],
      \ 'tabsel':  [ s:col(s:c.lavender, s:c.surface0, 'bold') ],
      \ 'middle':  [ s:col(s:c.overlay1, s:c.crust) ],
      \ 'right':   [ s:col(s:c.subtext0, s:c.mantle), s:col(s:c.crust, s:c.mauve, 'bold') ],
      \ }

" Entries are already in lightline's final form: [guifg, guibg, ctermfg, ctermbg, attr].
let g:lightline#colorscheme#my_palette#palette = s:p
unlet! s:mode s:acc
