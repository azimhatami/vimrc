" ==============================================================================
"  my#ui — palette, highlight overrides, theme switching, visual helpers
" ==============================================================================

" Palettes: one source of truth for every colour used by the overrides, the
" status line, fzf, the dashboard and the terminal. Every palette uses the same
" role names (Catppuccin's naming), so all UI code works with any theme.
"
"   space  — Space Vim Dark (github.com/liuchengxu/space-vim-dark, MIT, derived
"            from spacemacs-dark). Roles are mapped to the colours that scheme
"            itself uses; the extra keys at the end pin its signature look
"            (teal italic comments, purple selection, darker cursor line).
"   mocha / latte — Catppuccin (https://catppuccin.com/palette, MIT).
let s:palettes = {
      \ 'space': {
      \   'rosewater': '#d698fe', 'flamingo': '#e697e6', 'pink': '#df90ff', 'mauve': '#b888e2',
      \   'red': '#ce537a', 'maroon': '#e0211d', 'peach': '#e18254', 'yellow': '#d1951d',
      \   'green': '#67b11d', 'teal': '#2aa1ae', 'sky': '#74baac', 'sapphire': '#3c8380',
      \   'blue': '#4f97d7', 'lavender': '#bc6ec5', 'text': '#b2b2b2', 'subtext1': '#a8a8b8',
      \   'subtext0': '#9a9aba', 'overlay2': '#86869e', 'overlay1': '#727286', 'overlay0': '#5e5d70',
      \   'surface2': '#544a65', 'surface1': '#44404f', 'surface0': '#34323e', 'base': '#292b2e',
      \   'mantle': '#212026', 'crust': '#100a14',
      \   'comment': '#2aa1ae', 'linenr': '#44505c', 'cursorline': '#212026', 'visual': '#544a65',
      \   'float': '#34323e', 'select': '#5e5079', 'search': '#86dc2f', 'warn': '#dc752f',
      \   'mode_normal': '#bc6ec5', 'mode_insert': '#67b11d', 'mode_visual': '#d1951d',
      \   'mode_replace': '#ce537a', 'mode_command': '#4f97d7', 'mode_terminal': '#2aa1ae',
      \   'mode_select': '#df90ff' },
      \ 'mocha': {
      \   'rosewater': '#f5e0dc', 'flamingo': '#f2cdcd', 'pink': '#f5c2e7', 'mauve': '#cba6f7',
      \   'red': '#f38ba8', 'maroon': '#eba0ac', 'peach': '#fab387', 'yellow': '#f9e2af',
      \   'green': '#a6e3a1', 'teal': '#94e2d5', 'sky': '#89dceb', 'sapphire': '#74c7ec',
      \   'blue': '#89b4fa', 'lavender': '#b4befe', 'text': '#cdd6f4', 'subtext1': '#bac2de',
      \   'subtext0': '#a6adc8', 'overlay2': '#9399b2', 'overlay1': '#7f849c', 'overlay0': '#6c7086',
      \   'surface2': '#585b70', 'surface1': '#45475a', 'surface0': '#313244', 'base': '#1e1e2e',
      \   'mantle': '#181825', 'crust': '#11111b' },
      \ 'latte': {
      \   'rosewater': '#dc8a78', 'flamingo': '#dd7878', 'pink': '#ea76cb', 'mauve': '#8839ef',
      \   'red': '#d20f39', 'maroon': '#e64553', 'peach': '#fe640b', 'yellow': '#df8e1d',
      \   'green': '#40a02b', 'teal': '#179299', 'sky': '#04a5e5', 'sapphire': '#209fb5',
      \   'blue': '#1e66f5', 'lavender': '#7287fd', 'text': '#4c4f69', 'subtext1': '#5c5f77',
      \   'subtext0': '#6c6f85', 'overlay2': '#7c7f93', 'overlay1': '#8c8fa1', 'overlay0': '#9ca0b0',
      \   'surface2': '#acb0be', 'surface1': '#bcc0cc', 'surface0': '#ccd0da', 'base': '#eff1f5',
      \   'mantle': '#e6e9ef', 'crust': '#dce0e8' },
      \ }

" g:my_theme → palette:  'space' (default) · 'dark' = Catppuccin Mocha ·
" 'light' = Catppuccin Latte  ('mocha' / 'latte' are accepted as aliases).
function! my#ui#flavor() abort
  let l:t = get(g:, 'my_theme', 'space')
  if &background ==# 'light' || l:t =~# '^\%(light\|latte\)$'
    return 'latte'
  endif
  return l:t ==# 'space' ? 'space' : 'mocha'
endfunction

" Space Vim Dark background variants (g:my_space_background):
"   'default' #292b2e · 'darker' #212026 · 'darkest' #1a191f
" (The original scheme offers g:space_vim_dark_background = 233…238, but in
" true colour its 233 maps to #303030 — lighter than 234 — so the variants are
" defined here as hex values instead.)
let s:space_bg = {
      \ 'default': {'base': '#292b2e', 'mantle': '#212026', 'crust': '#100a14', 'cursorline': '#212026'},
      \ 'darker':  {'base': '#212026', 'mantle': '#1a191f', 'crust': '#0d0a10', 'cursorline': '#1a191f'},
      \ 'darkest': {'base': '#1a191f', 'mantle': '#141318', 'crust': '#09080b', 'cursorline': '#25232b'} }

function! my#ui#palette() abort
  let l:f = my#ui#flavor()
  if l:f !=# 'space' | return s:palettes[l:f] | endif
  let l:v = get(s:space_bg, get(g:, 'my_space_background', 'default'), s:space_bg.default)
  return extend(copy(s:palettes.space), l:v)
endfunction

" Display name of the active theme (status messages, :VimHealth, dashboard).
function! my#ui#theme_name() abort
  return {'space': 'Space Vim Dark', 'mocha': 'Catppuccin Mocha', 'latte': 'Catppuccin Latte'}[my#ui#flavor()]
endfunction

" ── Colour maths ──────────────────────────────────────────────────────────────
function! s:rgb(hex) abort
  return [str2nr(a:hex[1:2], 16), str2nr(a:hex[3:4], 16), str2nr(a:hex[5:6], 16)]
endfunction

" Blend two #rrggbb colours: t=0 → a, t=1 → b.
function! my#ui#mix(a, b, t) abort
  let [l:a, l:b] = [s:rgb(a:a), s:rgb(a:b)]
  return printf('#%02x%02x%02x',
        \ float2nr(round(l:a[0] + (l:b[0] - l:a[0]) * a:t)),
        \ float2nr(round(l:a[1] + (l:b[1] - l:a[1]) * a:t)),
        \ float2nr(round(l:a[2] + (l:b[2] - l:a[2]) * a:t)))
endfunction

" Nearest xterm-256 index for a #rrggbb colour (fallback when no true colour).
let s:cube = [0, 95, 135, 175, 215, 255]
let s:term_cache = {}
function! my#ui#to256(hex) abort
  if a:hex ==# 'NONE' | return 'NONE' | endif
  if has_key(s:term_cache, a:hex) | return s:term_cache[a:hex] | endif
  let l:c = s:rgb(a:hex)
  let l:best = [0, 1.0e9]
  " 6×6×6 colour cube
  let l:idx = map(copy(l:c), {_, v -> index(s:cube, s:nearest_level(v))})
  let l:cc = [s:cube[l:idx[0]], s:cube[l:idx[1]], s:cube[l:idx[2]]]
  let l:best = [16 + 36 * l:idx[0] + 6 * l:idx[1] + l:idx[2], s:dist(l:c, l:cc)]
  " 24-step grey ramp
  for l:i in range(24)
    let l:g = 8 + 10 * l:i
    let l:d = s:dist(l:c, [l:g, l:g, l:g])
    if l:d < l:best[1] | let l:best = [232 + l:i, l:d] | endif
  endfor
  let s:term_cache[a:hex] = l:best[0]
  return l:best[0]
endfunction

function! s:nearest_level(v) abort
  let l:best = 0
  for l:lv in s:cube
    if abs(l:lv - a:v) < abs(l:best - a:v) | let l:best = l:lv | endif
  endfor
  return l:best
endfunction

function! s:dist(a, b) abort
  return pow(a:a[0] - a:b[0], 2) + pow(a:a[1] - a:b[1], 2) + pow(a:a[2] - a:b[2], 2)
endfunction

" :highlight wrapper — gui + cterm in one call.
"   my#ui#hi('Group', {'fg': '#hex'|'NONE', 'bg': …, 'sp': …, 'attr': 'bold,italic'})
function! my#ui#hi(group, spec) abort
  let l:cmd = 'highlight ' . a:group
  " cterm fallbacks are only computed when they're actually used.
  let l:cterm = !&termguicolors
  if has_key(a:spec, 'fg')
    let l:cmd .= ' guifg=' . a:spec.fg . (l:cterm ? ' ctermfg=' . my#ui#to256(a:spec.fg) : '')
  endif
  if has_key(a:spec, 'bg')
    let l:cmd .= ' guibg=' . a:spec.bg . (l:cterm ? ' ctermbg=' . my#ui#to256(a:spec.bg) : '')
  endif
  if has_key(a:spec, 'sp')
    let l:cmd .= ' guisp=' . a:spec.sp
  endif
  let l:attr = get(a:spec, 'attr', 'NONE')
  let l:cmd .= ' gui=' . l:attr . ' cterm=' . l:attr
  execute l:cmd
endfunction

" ── Terminal capability detection ─────────────────────────────────────────────
function! my#ui#truecolor() abort
  return has('termguicolors') && (
        \   $COLORTERM =~# 'truecolor\|24bit'
        \ || $TERM =~# '-direct\|kitty\|alacritty\|wezterm\|foot\|ghostty'
        \ || $TERM_PROGRAM =~# 'iTerm\|WezTerm\|vscode\|ghostty'
        \ || str2nr($VTE_VERSION) >= 3600)
endfunction

" ── Theme application ─────────────────────────────────────────────────────────
function! my#ui#apply_theme(theme) abort
  let g:my_theme = {'mocha': 'dark', 'latte': 'light'}->get(a:theme, a:theme)
  if g:my_theme !~# '^\%(space\|dark\|light\)$' | let g:my_theme = 'space' | endif
  let s:applying = 1      " overrides() trusts g:my_theme while this runs
  try
    call s:apply()
  finally
    let s:applying = 0
  endtry
endfunction

function! s:apply() abort
  let &background = g:my_theme ==# 'light' ? 'light' : 'dark'
  if my#ui#truecolor()
    set termguicolors
  endif
  if !&termguicolors && str2nr(&t_Co) < 256
    " 8/16-colour terminal: keep Vim's default scheme, which is designed for it.
    silent! colorscheme default
    return
  endif
  try
    if my#ui#flavor() ==# 'space'
      " cterm-only shade for 256-colour terminals (true colour uses the palette).
      let g:space_vim_dark_background = {'darker': 234, 'darkest': 233}->get(get(g:, 'my_space_background', 'default'), 235)
      colorscheme space-vim-dark
    else
      execute 'colorscheme catppuccin_' . my#ui#flavor()
    endif
  catch
    " Theme plugin missing → Vim's built-in habamax (dark) / default (light).
    execute 'silent! colorscheme ' . (g:my_theme ==# 'light' ? 'default' : 'habamax')
  endtry
endfunction

function! s:restyle(theme) abort
  call my#ui#apply_theme(a:theme)
  call my#statusline#reload()
  echo 'Theme: ' . my#ui#theme_name()
endfunction

" <Space>tb — dark ↔ light. Returns to whichever dark theme you came from.
function! my#ui#toggle_theme() abort
  if g:my_theme ==# 'light'
    call s:restyle(get(g:, 'my_dark_theme', 'space'))
  else
    let g:my_dark_theme = g:my_theme
    call s:restyle('light')
  endif
endfunction

" <Space>tB — cycle Space Vim Dark → Catppuccin Mocha → Catppuccin Latte.
function! my#ui#cycle_theme() abort
  let l:order = ['space', 'dark', 'light']
  let l:next = l:order[(index(l:order, g:my_theme) + 1) % len(l:order)]
  if l:next !=# 'light' | let g:my_dark_theme = l:next | endif
  call s:restyle(l:next)
endfunction

" Highlight overrides layered on top of the colour scheme (UI chrome only:
" syntax colours stay the scheme's own). Runs on every ColorScheme event for
" space-vim-dark / catppuccin*, so it survives :colorscheme, Goyo, toggles.
function! my#ui#overrides() abort
  " Follow the scheme that was actually loaded: a raw `:colorscheme
  " catppuccin_mocha` must get the Mocha palette, not the previous theme's.
  " Schemes without a palette here (frappe, macchiato) keep their own colours.
  let l:managed = {'space-vim-dark': 'space', 'catppuccin_mocha': 'dark', 'catppuccin_latte': 'light'}
  if !get(s:, 'applying', 0)
    if !has_key(l:managed, get(g:, 'colors_name', '')) | return | endif
    let g:my_theme = l:managed[g:colors_name]
  endif
  let p = my#ui#palette()
  let bg = get(g:, 'my_transparent', 0) ? 'NONE' : p.base
  let cul   = get(p, 'cursorline', my#ui#mix(p.base, p.surface0, 0.55))
  let float = get(p, 'float', p.mantle)
  let sel   = get(p, 'select', p.surface0)
  call my#ui#hi('Normal',       {'fg': p.text, 'bg': bg})
  call my#ui#hi('EndOfBuffer',  {'fg': p.base, 'bg': 'NONE'})
  " Gutter: quiet numbers, a single lavender accent on the current line.
  call my#ui#hi('LineNr',       {'fg': get(p, 'linenr', p.surface2), 'bg': 'NONE'})
  call my#ui#hi('LineNrAbove',  {'fg': get(p, 'linenr', p.surface2), 'bg': 'NONE'})
  call my#ui#hi('LineNrBelow',  {'fg': get(p, 'linenr', p.surface2), 'bg': 'NONE'})
  call my#ui#hi('CursorLineNr', {'fg': p.lavender, 'bg': cul, 'attr': 'bold'})
  call my#ui#hi('CursorLine',   {'bg': cul})
  call my#ui#hi('CursorColumn', {'bg': cul})
  call my#ui#hi('SignColumn',   {'bg': 'NONE'})
  call my#ui#hi('FoldColumn',   {'fg': p.overlay0, 'bg': 'NONE'})
  call my#ui#hi('ColorColumn',  {'bg': p.mantle})
  call my#ui#hi('Folded',       {'fg': p.overlay1, 'bg': p.mantle, 'attr': 'italic'})
  call my#ui#hi('VertSplit',    {'fg': p.surface0, 'bg': 'NONE'})
  " Selection & search
  call my#ui#hi('Visual',       {'bg': get(p, 'visual', my#ui#mix(p.base, p.surface1, 0.85))})
  call my#ui#hi('VisualNOS',    {'bg': p.surface0})
  call my#ui#hi('Search',       {'fg': p.text, 'bg': my#ui#mix(p.base, get(p, 'search', p.blue), 0.32)})
  call my#ui#hi('IncSearch',    {'fg': p.crust, 'bg': p.peach, 'attr': 'bold'})
  call my#ui#hi('CurSearch',    {'fg': p.crust, 'bg': p.peach, 'attr': 'bold'})
  call my#ui#hi('MatchParen',   {'fg': p.peach, 'bg': my#ui#mix(p.base, p.peach, 0.18), 'attr': 'bold'})
  call my#ui#hi('QuickFixLine', {'bg': p.surface0, 'attr': 'bold'})
  " Invisible characters & indent guides (listchars use SpecialKey/NonText)
  call my#ui#hi('SpecialKey',   {'fg': my#ui#mix(p.base, p.surface1, 0.6)})
  call my#ui#hi('NonText',      {'fg': p.surface1})
  call my#ui#hi('ExtraWhitespace', {'bg': my#ui#mix(p.base, p.red, 0.45)})
  call my#ui#hi('YankFlash',    {'bg': my#ui#mix(p.base, p.peach, 0.38)})
  " Comments in italics (terminal permitting)
  call my#ui#hi('Comment',      {'fg': get(p, 'comment', p.overlay1), 'attr': 'italic'})
  " Pop-up menu / floating windows
  call my#ui#hi('Pmenu',        {'fg': p.subtext1, 'bg': float})
  call my#ui#hi('PmenuSel',     {'fg': p.text, 'bg': sel, 'attr': 'bold'})
  call my#ui#hi('PmenuSbar',    {'bg': float})
  call my#ui#hi('PmenuThumb',   {'bg': p.surface2})
  call my#ui#hi('PmenuKind',    {'fg': p.mauve, 'bg': float})
  call my#ui#hi('PmenuKindSel', {'fg': p.mauve, 'bg': sel, 'attr': 'bold'})
  call my#ui#hi('PmenuExtra',   {'fg': p.overlay1, 'bg': float})
  call my#ui#hi('PmenuExtraSel',{'fg': p.overlay2, 'bg': sel})
  call my#ui#hi('PmenuMatch',   {'fg': p.blue, 'bg': float, 'attr': 'bold'})
  call my#ui#hi('PmenuMatchSel',{'fg': p.blue, 'bg': sel, 'attr': 'bold'})
  call my#ui#hi('FloatBorder',  {'fg': p.surface2, 'bg': float})
  call my#ui#hi('FloatTitle',   {'fg': p.lavender, 'bg': float, 'attr': 'bold'})
  call my#ui#hi('WildMenu',     {'fg': p.crust, 'bg': p.blue, 'attr': 'bold'})
  " Diff: tinted backgrounds instead of loud blocks
  call my#ui#hi('DiffAdd',      {'bg': my#ui#mix(p.base, p.green, 0.18)})
  call my#ui#hi('DiffChange',   {'bg': my#ui#mix(p.base, p.blue, 0.12)})
  call my#ui#hi('DiffText',     {'bg': my#ui#mix(p.base, p.blue, 0.30)})
  call my#ui#hi('DiffDelete',   {'fg': my#ui#mix(p.base, p.red, 0.45), 'bg': my#ui#mix(p.base, p.red, 0.14)})
  " Git signs
  call my#ui#hi('GitGutterAdd',          {'fg': p.green, 'bg': 'NONE'})
  call my#ui#hi('GitGutterChange',       {'fg': p.yellow, 'bg': 'NONE'})
  call my#ui#hi('GitGutterDelete',       {'fg': p.red, 'bg': 'NONE'})
  call my#ui#hi('GitGutterChangeDelete', {'fg': p.peach, 'bg': 'NONE'})
  " LSP diagnostics: coloured signs, tinted virtual text, undercurls
  for [l:kind, l:col] in [['Error', p.red], ['Warning', p.yellow], ['Information', p.sky], ['Hint', p.teal]]
    call my#ui#hi('Lsp' . l:kind . 'Text',        {'fg': l:col, 'bg': 'NONE'})
    call my#ui#hi('Lsp' . l:kind . 'VirtualText', {'fg': my#ui#mix(p.base, l:col, 0.8), 'bg': my#ui#mix(p.base, l:col, 0.09), 'attr': 'italic'})
    call my#ui#hi('Lsp' . l:kind . 'Highlight',   {'sp': l:col, 'attr': l:kind =~# 'Error\|Warning' ? 'undercurl' : 'underline'})
  endfor
  call my#ui#hi('lspReference',          {'bg': my#ui#mix(p.base, p.surface1, 0.7)})
  call my#ui#hi('LspCodeActionText',     {'fg': p.yellow, 'bg': 'NONE'})
  call my#ui#hi('lspInlayHintsType',     {'fg': p.overlay0, 'attr': 'italic'})
  call my#ui#hi('lspInlayHintsParameter',{'fg': p.overlay0, 'attr': 'italic'})
  " which-key
  call my#ui#hi('WhichKey',          {'fg': p.mauve, 'attr': 'bold'})
  call my#ui#hi('WhichKeySeperator', {'fg': p.surface2})
  call my#ui#hi('WhichKeyGroup',     {'fg': p.blue, 'attr': 'bold'})
  call my#ui#hi('WhichKeyDesc',      {'fg': p.text})
  call my#ui#hi('WhichKeyFloating',  {'bg': float})
  " fern explorer
  call my#ui#hi('FernRootSymbol',   {'fg': p.overlay0})
  call my#ui#hi('FernRootText',     {'fg': p.mauve, 'attr': 'bold'})
  call my#ui#hi('FernBranchSymbol', {'fg': p.overlay1})
  call my#ui#hi('FernBranchText',   {'fg': p.blue})
  call my#ui#hi('FernLeafSymbol',   {'fg': p.overlay0})
  call my#ui#hi('FernMarkedLine',   {'bg': p.surface0})
  call my#ui#hi('FernMarkedText',   {'fg': p.yellow, 'attr': 'bold'})
  " Start screen (Startify)
  call my#ui#hi('StartifyHeader',  {'fg': p.lavender, 'attr': 'bold'})
  call my#ui#hi('StartifySection', {'fg': p.blue, 'attr': 'bold'})
  call my#ui#hi('StartifyNumber',  {'fg': p.yellow})
  call my#ui#hi('StartifyBracket', {'fg': p.overlay0})
  call my#ui#hi('StartifyFile',    {'fg': p.text})
  call my#ui#hi('StartifyPath',    {'fg': p.overlay1})
  call my#ui#hi('StartifySlash',   {'fg': p.overlay0})
  call my#ui#hi('StartifySpecial', {'fg': p.overlay1, 'attr': 'italic'})
  call my#ui#hi('StartifyFooter',  {'fg': p.overlay1})
  call my#ui#hi('StartifyVar',     {'fg': p.teal})
  call my#ui#hi('StartifySelect',  {'fg': p.mauve})
  " Symbol outline (Vista)
  call my#ui#hi('VistaTag',        {'fg': p.lavender})
  call my#ui#hi('VistaKind',       {'fg': p.blue, 'attr': 'bold'})
  call my#ui#hi('VistaScope',      {'fg': p.mauve, 'attr': 'bold'})
  call my#ui#hi('VistaLineNr',     {'fg': p.overlay0})
  call my#ui#hi('VistaColon',      {'fg': p.overlay0})
  call my#ui#hi('VistaIcon',       {'fg': p.teal})
  call my#ui#hi('VistaPublic',     {'fg': p.green})
  call my#ui#hi('VistaPrivate',    {'fg': p.red})
  call my#ui#hi('VistaProtected',  {'fg': p.yellow})
  " Floating terminal and the tool sidebars share the darker panel colour.
  call my#ui#hi('MyFloatTerm',     {'fg': p.text, 'bg': p.mantle})
  call my#ui#hi('MyPanel',         {'fg': p.text, 'bg': p.mantle})
  call my#ui#hi('MyPanelEnd',      {'fg': p.mantle, 'bg': p.mantle})
  " Snippet placeholders (vim-vsnip) and :s previews (traces.vim)
  call my#ui#hi('VsnipMarker',     {'bg': my#ui#mix(p.base, p.mauve, 0.20)})
  highlight! link TracesSearch Search
  highlight! link TracesReplace IncSearch
  " Messages / titles in the scheme's accent colours
  call my#ui#hi('Title',           {'fg': p.lavender, 'attr': 'bold'})
  call my#ui#hi('ModeMsg',         {'fg': p.text, 'attr': 'bold'})
  call my#ui#hi('Directory',       {'fg': p.blue, 'attr': 'bold'})
  " Terminal-mode status lines blend with lightline
  highlight! link StatusLineTerm   StatusLine
  highlight! link StatusLineTermNC StatusLineNC
  " Colours for :terminal and fzf (bright black lifted for readability).
  let g:terminal_ansi_colors = [
        \ p.surface1, p.red, p.green, p.yellow, p.blue, p.pink, p.teal, p.subtext1,
        \ p.surface2, p.red, p.green, p.yellow, p.blue, p.pink, p.teal, p.subtext0]
endfunction

" Minimal fallbacks for non-Catppuccin schemes (so custom groups always exist).
function! my#ui#generic_overrides() abort
  highlight default link ExtraWhitespace Error
  highlight default link YankFlash IncSearch
  highlight default link FloatBorder Pmenu
endfunction

" ── Fold text:  ▸ def handler(request):  ·····························  12 lines
function! my#ui#foldtext() abort
  let l:line  = substitute(getline(v:foldstart), '\t', repeat(' ', &tabstop), 'g')
  let l:line  = substitute(l:line, '\s*\%({{{\|}}}\)\d*\s*$', '', '')
  let l:count = v:foldend - v:foldstart + 1
  let l:right = printf(' %d lines ', l:count)
  let l:width = winwidth(0) - &numberwidth - &foldcolumn - (&signcolumn ==# 'no' ? 0 : 2) - 1
  let l:left  = '▸ ' . trim(l:line, ' ', 2) . ' '
  let l:fill  = l:width - strdisplaywidth(l:left) - strdisplaywidth(l:right)
  return l:left . repeat('·', max([l:fill, 2])) . l:right
endfunction

" ── Indent guides via 'listchars' (zero-cost; no plugin, no conceal) ──────────
let s:no_guides_ft = ['help', 'fern', 'fugitive', 'git', 'qf', 'man', 'undotree', 'diff', 'markdown', 'text', 'gitcommit', 'fzf', 'which_key']
function! my#ui#listchars() abort
  if &buftype =~# 'terminal\|nofile\|help\|quickfix' || index(s:no_guides_ft, &filetype) >= 0
    setlocal nolist
    return
  endif
  setlocal list
  let l:base = 'trail:·,nbsp:␣,extends:›,precedes:‹'
  if get(g:, 'my_indent_guides', 1)
    let l:sw = max([shiftwidth(), 1])
    let &l:listchars = 'tab:│ ,leadmultispace:│' . repeat(' ', l:sw - 1) . ',' . l:base
  else
    let &l:listchars = 'tab:  ,' . l:base
  endif
endfunction

function! my#ui#toggle_indent_guides() abort
  let g:my_indent_guides = !get(g:, 'my_indent_guides', 1)
  let l:cur = winnr()
  windo call my#ui#listchars()
  execute l:cur . 'wincmd w'
  echo 'Indent guides: ' . (g:my_indent_guides ? 'on' : 'off')
endfunction

" ── Trailing whitespace highlight (normal file buffers only) ──────────────────
function! my#ui#whitespace(insert) abort
  if exists('w:my_ws_match')
    silent! call matchdelete(w:my_ws_match)
    unlet w:my_ws_match
  endif
  if &buftype !=# '' || !&modifiable || &filetype =~# '^\%(fern\|help\|fugitive\|git\|diff\|markdown\)$'
    return
  endif
  " While typing, don't flag the whitespace right before the cursor.
  let w:my_ws_match = matchadd('ExtraWhitespace', a:insert ? '\s\+\%#\@<!$' : '\s\+$', -1)
endfunction

" ── Yank flash ────────────────────────────────────────────────────────────────
function! my#ui#yank_flash() abort
  if v:event.operator !=# 'y'
    return
  endif
  let [l:s, l:e] = [getpos("'["), getpos("']")]
  " Skip empty marks and huge yanks (ggyG) — the flash isn't worth the redraw.
  if l:s[1] == 0 || l:e[1] - l:s[1] > 400 | return | endif
  if v:event.regtype ==# 'V'
    let l:pat = '\%>' . (l:s[1] - 1) . 'l\%<' . (l:e[1] + 1) . 'l'
  elseif v:event.regtype[0] ==# "\<C-v>"
    let l:pat = '\%>' . (l:s[1] - 1) . 'l\%<' . (l:e[1] + 1) . 'l\%>' . (min([l:s[2], l:e[2]]) - 1) . 'v\%<' . (max([l:s[2], l:e[2]]) + 1) . 'v'
  else
    let l:pat = '\%' . l:s[1] . 'l\%' . l:s[2] . 'c\_.*\%' . l:e[1] . 'l\%' . l:e[2] . 'c.'
  endif
  let l:id = matchadd('YankFlash', l:pat, 100)
  let l:win = win_getid()
  call timer_start(180, {-> s:clear_match(l:win, l:id)})
endfunction

function! s:clear_match(win, id) abort
  silent! call matchdelete(a:id, a:win)
endfunction

" ── Hybrid line numbers: relative where you navigate, absolute elsewhere ─────
function! my#ui#numbers(focused) abort
  if !&number || get(w:, 'my_no_rnu', 0) || &buftype !=# '' && &buftype !=# 'acwrite'
    return
  endif
  let &l:relativenumber = a:focused
endfunction

" ── Distraction-free mode (Goyo) ──────────────────────────────────────────────
function! my#ui#goyo_enter() abort
  let s:goyo_saved = {'list': &list, 'showcmd': &showcmd, 'scrolloff': &scrolloff}
  silent! call lightline#disable()
  set noshowcmd scrolloff=999
  setlocal nolist nocursorline
  if exists(':GitGutterBufferDisable') | silent! GitGutterBufferDisable | endif
endfunction

function! my#ui#goyo_leave() abort
  if exists('s:goyo_saved')
    let &showcmd = s:goyo_saved.showcmd
    let &scrolloff = s:goyo_saved.scrolloff
  endif
  silent! call lightline#enable()
  call my#ui#listchars()
  setlocal cursorline
  if exists(':GitGutterBufferEnable') | silent! GitGutterBufferEnable | endif
endfunction

" ── Theme preview (Space t p / :ThemePreview) ─────────────────────────────────
" A pop-up list of every installed colour scheme. Moving the selection applies
" it live; <CR> keeps it for this session, <Esc>/q restores what you had.
" Nothing is ever written to disk: the default stays g:my_theme (local.vim).
function! s:preview_items() abort
  let l:items = [
        \ ['Space Vim Dark            default',        ['space', 'default']],
        \ ['Space Vim Dark · darker   background',     ['space', 'darker']],
        \ ['Space Vim Dark · darkest  background',     ['space', 'darkest']],
        \ ['Catppuccin Mocha          dark',           ['dark', '']],
        \ ['Catppuccin Latte          light',          ['light', '']]]
  for l:c in getcompletion('', 'color')
    if l:c =~# '^\%(space-vim-dark\|catppuccin\|catppuccin_mocha\|catppuccin_latte\)$' | continue | endif
    call add(l:items, [printf('%-25s %s', l:c, l:c =~# '^catppuccin' ? 'plugin, unmanaged' : 'built into Vim'), ['raw', l:c]])
  endfor
  return l:items
endfunction

function! s:preview_apply(spec) abort
  if a:spec[0] ==# 'raw'
    execute 'silent! colorscheme ' . a:spec[1]
  else
    if a:spec[0] ==# 'space' | let g:my_space_background = a:spec[1] | endif
    call my#ui#apply_theme(a:spec[0])
  endif
  call my#statusline#reload()
  redraw
endfunction

function! s:preview_restore() abort
  if s:pv_saved.bg is v:null | unlet! g:my_space_background | else | let g:my_space_background = s:pv_saved.bg | endif
  call s:preview_apply([s:pv_saved.theme, get(g:, 'my_space_background', 'default')])
endfunction

function! s:preview_filter(id, key) abort
  if a:key ==# 'q' || a:key ==# "\<Esc>"
    call popup_close(a:id, -1) | return 1
  endif
  let l:before = line('.', a:id)
  let l:handled = popup_filter_menu(a:id, a:key)
  if !empty(popup_getpos(a:id)) && line('.', a:id) != l:before
    call s:preview_apply(s:pv_items[line('.', a:id) - 1][1])
  endif
  return l:handled
endfunction

function! s:preview_done(id, result) abort
  if a:result < 1
    call s:preview_restore()
    echo 'Theme restored: ' . my#ui#theme_name()
  else
    let l:it = s:pv_items[a:result - 1]
    call s:preview_apply(l:it[1])
    echo 'Theme for this session: ' . trim(l:it[0][:24]) . '.  Default unchanged — make it permanent with g:my_theme in ~/.vim/local.vim'
  endif
endfunction

function! my#ui#preview() abort
  let s:pv_saved = {'theme': g:my_theme, 'bg': get(g:, 'my_space_background', v:null)}
  let s:pv_items = s:preview_items()
  let l:id = popup_menu(map(copy(s:pv_items), 'v:val[0]'), {
        \ 'title': ' Themes — j/k preview · Enter keep for this session · Esc restore ',
        \ 'pos': 'topright', 'line': 3, 'col': &columns - 2, 'maxheight': &lines - 8,
        \ 'border': [], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'borderhighlight': ['FloatBorder'], 'highlight': 'Pmenu', 'padding': [0, 1, 0, 1],
        \ 'filter': function('s:preview_filter'), 'callback': function('s:preview_done')})
  " Start on the entry that matches the current theme.
  let l:cur = g:my_theme ==# 'space' ? index(['default', 'darker', 'darkest'], get(g:, 'my_space_background', 'default')) + 1
        \ : g:my_theme ==# 'dark' ? 4 : 5
  call win_execute(l:id, 'call cursor(' . max([l:cur, 1]) . ', 1)')
endfunction

function! my#ui#theme_names(lead, line, pos) abort
  return filter(['space', 'dark', 'light'], 'stridx(v:val, a:lead) == 0')
endfunction

" :Theme [space|dark|light] — switch by name; no argument restores the default
" from ~/.vim/local.vim (or Space Vim Dark).
function! my#ui#set(name) abort
  let l:t = empty(a:name) ? get(g:, 'my_default_theme', 'space') : a:name
  call s:restyle(l:t)
endfunction
