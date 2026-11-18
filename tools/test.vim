" ==============================================================================
"  tools/test.vim — automated checks for this configuration
"
"    vim -Nu ~/.vim/vimrc -es -S ~/.vim/tools/test.vim        (prints PASS/FAIL)
"    ~/.vim/tools/check.sh                                 (wrapper + timing)
" ==============================================================================

" Never stop at a -- More -- or hit-enter prompt: in Ex mode those read
" stdin, and an exhausted stdin makes Vim exit early.
set nomore
let s:results = []
let s:fails = 0
" -S runs before VimEnter; fire it so VimEnter-time setup (lexima, which-key)
" happens. silent!: a synthetic VimEnter has no <afile>, which Vim's bundled
" editorconfig handler trips over (a real startup is unaffected — verified).
silent! doautocmd <nomodeline> VimEnter

" Any unexpected error is reported as a FAIL instead of aborting the suite.
try
function! s:check(ok, name, ...) abort
  let l:detail = a:0 ? a:1 : ''
  call add(s:results, printf('%s  %s%s', a:ok ? 'PASS' : 'FAIL', a:name, empty(l:detail) ? '' : '  — ' . l:detail))
  if exists('g:my_test_progress') | call writefile([s:results[-1]], g:my_test_progress, 'a') | endif
  if !a:ok | let s:fails += 1 | endif
endfunction

" 1. Startup ─────────────────────────────────────────────────────────────────
call s:check(empty(g:my_errors), 'startup: no module errors', join(g:my_errors, ' | '))
for s:m in ['options', 'plugins', 'appearance', 'navigation', 'dashboard', 'editing', 'git', 'lsp', 'languages', 'mappings', 'whichkey']
  let s:f = expand('~/.vim/config/' . s:m . '.vim')
  call s:check(filereadable(s:f) && !empty(filter(split(execute('scriptnames'), "\n"), 'v:val =~# "config/' . s:m . '.vim"')), 'module sourced: ' . s:m)
endfor

" 2. Plugins ─────────────────────────────────────────────────────────────────
let s:missing = filter(keys(g:plugs), '!isdirectory(g:plugs[v:val].dir)')
call s:check(empty(s:missing), 'plugins: all ' . len(g:plugs) . ' installed', join(s:missing, ', '))
call s:check(filereadable(expand('~/.vim/plug-snapshot.vim')), 'plugins: lockfile ~/.vim/plug-snapshot.vim exists')
for [s:p, s:probe] in [['lightline.vim', 'g:loaded_lightline'], ['vim-fugitive', 'g:loaded_fugitive'],
      \ ['vim-gitgutter', 'g:loaded_gitgutter'], ['vim-lsp', 'g:lsp_loaded'], ['asyncomplete.vim', 'g:asyncomplete_loaded'],
      \ ['vim-surround', 'g:loaded_surround'], ['vim-commentary', 'g:loaded_commentary'], ['lexima.vim', 'g:loaded_lexima'],
      \ ['targets.vim', 'g:loaded_targets'], ['vim-fern', 'g:loaded_fern'], ['fzf.vim', 'g:loaded_fzf_vim'],
      \ ['vim-startify', 'g:loaded_startify'], ['vim-vsnip', 'g:loaded_vsnip'], ['vim-vsnip-integ', 'g:loaded_vsnip_integ'],
      \ ['traces.vim', 'g:loaded_traces_plugin'], ['vim-eunuch', 'g:loaded_eunuch']]
  call s:check(exists(s:probe), 'plugin loaded: ' . s:p, s:probe)
endfor
call s:check(exists(':UndotreeToggle') == 2, 'lazy plugin stub: undotree (:UndotreeToggle)')
call s:check(exists(':Goyo') == 2, 'lazy plugin stub: goyo (:Goyo)')
call s:check(exists(':Vista') == 2 && !exists('g:loaded_vista'), 'lazy plugin stub: vista (:Vista, not loaded at startup)')
call s:check(empty(maparg('<CR>', 'i')) || maparg('<CR>', 'i') !~# 'Eunuch', 'eunuch does not wrap insert <CR>', maparg('<CR>', 'i'))

" 3. Appearance ──────────────────────────────────────────────────────────────
call s:check(get(g:, 'colors_name', '') ==# 'space-vim-dark' && g:my_theme ==# 'space', 'colorscheme space-vim-dark (default)', get(g:, 'colors_name', 'none'))
call s:check(&termguicolors, 'true colour enabled ($COLORTERM=' . $COLORTERM . ')')
call s:check(synIDattr(hlID('CursorLineNr'), 'fg#') ==# '#bc6ec5', 'override: CursorLineNr space purple', synIDattr(hlID('CursorLineNr'), 'fg#'))
call s:check(synIDattr(hlID('Comment'), 'fg#') ==# '#2aa1ae' && synIDattr(hlID('Comment'), 'italic') ==# '1', 'space-vim-dark signature: teal italic comments')
call s:check(synIDattr(hlID('Normal'), 'bg#') ==# '#292b2e', 'space-vim-dark background #292b2e', synIDattr(hlID('Normal'), 'bg#'))
call s:check(synIDattr(hlID('GitGutterAdd'), 'fg#') ==# '#67b11d', 'override: GitGutterAdd green')
call s:check(synIDattr(hlID('Function'), 'fg#') ==# '#bc6ec5', 'syntax colours stay the scheme''s own (Function)', synIDattr(hlID('Function'), 'fg#'))
call s:check(hlexists('StartifyHeader') && synIDattr(hlID('StartifyHeader'), 'fg#') ==# '#bc6ec5', 'dashboard highlights follow the palette')
call s:check(synIDattr(hlID('LspErrorHighlight'), 'undercurl') ==# '1', 'override: LSP errors undercurled')
call s:check(exists('g:lightline#colorscheme#my_palette#palette'), 'lightline palette generated')
call s:check(g:lightline#colorscheme#my_palette#palette.normal.left[0][1] ==# '#bc6ec5', 'status line NORMAL uses the space accent', string(g:lightline#colorscheme#my_palette#palette.normal.left[0]))
call s:check(&statusline =~# 'lightline', 'status line driven by lightline', &statusline[:40])
call s:check(&tabline =~# 'lightline', 'buffer line driven by lightline')
for s:fn in ['mode', 'git', 'filename', 'errors', 'warnings', 'infos', 'lsp', 'filetype', 'fileinfo', 'position', 'percent', 'cwd', 'tabs']
  try
    let s:out = call('my#statusline#' . s:fn, [])
    call s:check(type(s:out) == v:t_string, 'statusline component: ' . s:fn, string(s:out))
  catch
    call s:check(0, 'statusline component: ' . s:fn, v:exception)
  endtry
endfor
" Theme toggle round-trip
call my#ui#toggle_theme()
call s:check(get(g:, 'colors_name', '') ==# 'catppuccin_latte' && &background ==# 'light', 'theme toggle → latte')
call my#ui#toggle_theme()
call s:check(get(g:, 'colors_name', '') ==# 'space-vim-dark' && synIDattr(hlID('CursorLineNr'), 'fg#') ==# '#bc6ec5', 'theme toggle → back to space-vim-dark, overrides re-applied')
call my#ui#cycle_theme()
call s:check(get(g:, 'colors_name', '') ==# 'catppuccin_mocha' && synIDattr(hlID('CursorLineNr'), 'fg#') ==# '#b4befe', 'theme cycle → catppuccin mocha')
call my#ui#toggle_theme() | call my#ui#toggle_theme()
call s:check(get(g:, 'colors_name', '') ==# 'catppuccin_mocha', 'light toggle returns to the dark theme you came from (mocha)')
call my#ui#cycle_theme() | call my#ui#cycle_theme()
call s:check(get(g:, 'colors_name', '') ==# 'space-vim-dark' && g:my_theme ==# 'space', 'theme cycle wraps around to space-vim-dark')
let g:my_space_background = 'darker' | call my#ui#apply_theme('space')
call s:check(synIDattr(hlID('Normal'), 'bg#') ==# '#212026', 'g:my_space_background = darker', synIDattr(hlID('Normal'), 'bg#'))
unlet g:my_space_background | call my#ui#apply_theme('space') | call my#statusline#reload()

" Icons: every defined sign must have visible text (catches stripped glyphs).
doautocmd <nomodeline> User lsp_setup
let s:empty_signs = map(filter(sign_getdefined(), 'has_key(v:val, "text") && strdisplaywidth(trim(v:val.text)) == 0'), 'v:val.name')
call s:check(empty(s:empty_signs), 'signs: all sign texts visible', join(s:empty_signs, ', '))
let s:empty_sym = filter(['branch', 'error', 'warning', 'lsp', 'line', 'folder'], 'empty(trim(my#statusline#_sym(v:val)))')
call s:check(!g:my_icons || empty(s:empty_sym), 'icons: status line glyphs non-empty', join(s:empty_sym, ', '))

" 4. Mappings ────────────────────────────────────────────────────────────────
let s:mapped = filter(copy(g:my_keys), 'v:val.kind ==# "map"')
let s:bad = []
for s:e in s:mapped
  for s:md in split(s:e.modes, '\zs')
    if empty(maparg(s:e.lhs, s:md))
      call add(s:bad, s:md . ':' . s:e.lhs)
    endif
  endfor
endfor
call s:check(empty(s:bad), 'registry: all ' . len(s:mapped) . ' mappings are active', join(s:bad, ', '))
" Duplicates in the registry
let s:seen = {}
let s:dups = []
for s:e in g:my_keys
  for s:md in split(s:e.modes, '\zs')
    let s:id = s:e.kind . s:md . s:e.lhs . '@' . s:e.scope
    if has_key(s:seen, s:id) | call add(s:dups, s:md . ':' . s:e.lhs) | endif
    let s:seen[s:id] = 1
  endfor
endfor
call s:check(empty(s:dups), 'registry: no duplicate entries', join(s:dups, ', '))
" Every leader mapping must belong to a which-key group (or be a top-level key)
let s:orph = []
for s:e in filter(copy(s:mapped), 'v:val.lhs =~? "^<leader>"')
  let s:tok = substitute(s:e.lhs, '\c<leader>', '', '')
  if strchars(s:tok) > 1 && s:tok[0] !=# '<' && !has_key(g:which_key_map, s:tok[0])
    call add(s:orph, s:e.lhs)
  endif
endfor
call s:check(empty(s:orph), 'which-key: every leader map is in a group', join(s:orph, ', '))
call s:check(has_key(g:which_key_map, 'f') && has_key(g:which_key_map.f, 'f'), 'which-key: dictionary populated (f.f = ' . get(get(g:which_key_map, 'f', {}), 'f', '?') . ')')
" Prefix conflicts: a mapping that is a strict prefix of another makes Vim
" wait 'timeoutlen'. Compared on raw key bytes. Only conflicts that involve a
" mapping defined by this config are reported (plugin-internal operator
" designs such as gc/gcc or ys/yss are intentional). targets.vim's i/a read
" the following key themselves, so they never time out.
let s:mine = {}
for s:si in getscriptinfo()
  if s:si.name =~# '/\.vim/config/\|/\.vimrc$\|/\.vim/vimrc$\|/\.vim/autoload/my/'
    let s:mine[s:si.sid] = 1
  endif
endfor
let s:conf = []
for s:md in ['n', 'x', 'o', 'i', 'c', 't']
  let s:maps = filter(maplist(), {_, m -> (m.mode =~# s:md || m.mode ==# ' ' && s:md =~# '[nxo]') && !m.buffer && m.lhs !~# '^<Plug>\|^<SNR>'})
  for s:a in s:maps
    if s:a.lhs ==# ' ' || s:a.lhs ==# '<Space>' | continue | endif
    for s:b in s:maps
      if s:b.lhsraw !=# s:a.lhsraw && stridx(s:b.lhsraw, s:a.lhsraw) == 0
            \ && (has_key(s:mine, s:a.sid) || has_key(s:mine, s:b.sid))
            \ && !(s:md =~# '[xo]' && s:a.lhs =~# '^[ia]$')
        call add(s:conf, s:md . ':' . s:a.lhs . ' < ' . s:b.lhs)
        break
      endif
    endfor
  endfor
endfor
call s:check(empty(s:conf), 'mappings: no prefix conflicts involving custom maps', join(uniq(sort(s:conf)), ', '))

" 5. Navigation ──────────────────────────────────────────────────────────────
for s:t in ['fzf', 'rg', 'fd', 'git']
  call s:check(executable(s:t), 'executable: ' . s:t, exepath(s:t))
endfor
for s:c in ['Files', 'GFiles', 'RG', 'Rg', 'Buffers', 'History', 'BLines', 'Commits', 'ProjectFiles', 'GrepWord', 'DirFiles', 'Fern']
  call s:check(exists(':' . s:c) == 2, 'command exists: :' . s:c)
endfor
call s:check($FZF_DEFAULT_COMMAND =~# '^fd ', 'fzf source command uses fd', $FZF_DEFAULT_COMMAND)
call s:check(&grepprg =~# '^rg', 'grepprg uses ripgrep', &grepprg)

" 5b. Explorer sidebar (startup behaviour is tested in a real pty — see README)
call s:check(get(g:, 'my_explorer_autostart', 0) == 1 && g:fern#drawer_width == 30, 'sidebar: autostart on, 30 columns wide')
call s:check(exists('#my_fern_sidebar#VimEnter') && exists('#my_fern_sidebar#QuitPre')
      \ && exists('#my_fern_sidebar#SessionLoadPost') && exists('#my_fern_sidebar#WinClosed'), 'sidebar: startup/quit/session autocmds installed')
call s:check(get(g:, 'my_explorer_autostart_skipped', '') =~# 'batch' && !my#fern#drawer_winnr(),
      \ 'sidebar: not opened in batch mode (vim -es)', get(g:, 'my_explorer_autostart_skipped', '<unset>'))
silent! only | enew!
let s:ed = win_getid()
call my#fern#open_sidebar(getcwd(), 1)
call my#fern#open_sidebar(getcwd(), 1)
call s:check(winnr('$') == 2 && my#fern#drawer_winnr() == 1 && win_getid() == s:ed && winwidth(1) == 30,
      \ 'sidebar: opens once on the left, 30 cols, cursor stays in the editor', winnr('$') . ' windows')
call my#fern#close()
call s:check(winnr('$') == 1 && !my#fern#drawer_winnr() && win_getid() == s:ed, 'sidebar: close keeps the editor')
call my#fern#open_sidebar(getcwd(), 0)
call my#fern#close()
call s:check(winnr('$') == 1 && !my#fern#is_drawer(), 'sidebar: closing the last window (the tree) leaves an editor, never quits')
silent! only | enew!

" 5c. Dashboard (startup itself is tested in a real pty — see README)
call s:check(get(g:, 'my_dashboard_skipped', '') =~# 'batch', 'dashboard: not opened in batch mode', get(g:, 'my_dashboard_skipped', '<unset>'))
call s:check(g:startify_disable_at_vimenter == 1 && exists(':Startify') == 2, 'dashboard: started by this config, not by Startify itself')
let s:hdr = my#dashboard#header()
call s:check(len(s:hdr) > 6 && join(s:hdr) =~# 'Space Vim Dark' && join(s:hdr) =~# 'plugins', 'dashboard: header shows version, theme, plugin count', string(s:hdr[-3:]))
for s:fn in ['recent', 'projects', 'sessions']
  try
    let s:out = call('my#dashboard#' . s:fn, [])
    call s:check(type(s:out) == v:t_list && empty(filter(copy(s:out), '!has_key(v:val, "line")')), 'dashboard list: ' . s:fn, len(s:out) . ' entries')
  catch
    call s:check(0, 'dashboard list: ' . s:fn, v:exception)
  endtry
endfor
let s:cwdp = fnamemodify(getcwd(), ':p')
call s:check(empty(filter(my#dashboard#recent(), 'stridx(v:val.path, s:cwdp) == 0')), 'dashboard: "elsewhere" list excludes the current project')
call s:check(index(g:startify_custom_indices, 'e') < 0 && index(g:startify_custom_indices, 'q') < 0 && index(g:startify_custom_indices, 'f') < 0,
      \ 'dashboard: entry indices never shadow Startify keys or the f/g/r/l/c/h commands')

" 5d. Python virtualenv + pyright interpreter
let s:venv = tempname()
call mkdir(s:venv . '/.venv/bin', 'p') | call mkdir(s:venv . '/pkg', 'p')
call writefile(['#!/bin/sh'], s:venv . '/.venv/bin/python') | call setfperm(s:venv . '/.venv/bin/python', 'rwxr-xr-x')
call s:check(my#run#python(s:venv . '/pkg') ==# fnamemodify(s:venv, ':p') . '.venv/bin/python', 'python: project .venv detected from a subdirectory', my#run#python(s:venv . '/pkg'))
execute 'edit ' . s:venv . '/pkg/m.py'
call s:check(get(get(my#lsp#pyright_settings(), 'python', {}), 'pythonPath', '') =~# '\.venv/bin/python$', 'pyright: pythonPath points at the project venv')
bwipeout!

" 5e. Snippets
let s:snf = tempname() . '.py'
execute 'edit ' . s:snf
let s:words = map(vsnip#get_complete_items(bufnr('%')), 'v:val.word')
call s:check(index(s:words, 'main') >= 0 && index(s:words, 'fixture') >= 0, 'snippets: personal python snippets load (main, fixture)', len(s:words) . ' items')
call s:check(index(s:words, 'def') >= 0 || index(s:words, 'class') >= 0, 'snippets: friendly-snippets python collection loads')
call s:check(maparg('<C-j>', 'i') =~# 'vsnip' && maparg('<C-k>', 's') =~# 'vsnip', 'snippets: <C-j>/<C-k> mapped in insert and select mode')
bwipeout!

" 5f. Make targets
let s:mk = tempname()
call writefile(['CC := gcc', '.PHONY: all test', 'all: main.o', "\tgcc main.o", 'test:', 'flash: all', '%.o: %.c', 'clean::'], s:mk)
call s:check(my#run#make_targets(s:mk) ==# ['all', 'clean', 'flash', 'test'], 'make: targets parsed (no variables, patterns, .PHONY)', string(my#run#make_targets(s:mk)))
call s:check(maparg('<leader>rM', 'n') =~# 'make_flash' && execute('function my#run#make_flash') =~# 'confirm', 'make flash always asks for confirmation')

" 6. Git ─────────────────────────────────────────────────────────────────────
let s:repo = tempname()
call mkdir(s:repo, 'p')
call system('cd ' . s:repo . ' && git init -q -b main && git config user.email t@t && git config user.name t && printf "a\nb\nc\n" > f.txt && git add f.txt && git commit -qm init')
execute 'edit ' . s:repo . '/f.txt'
call s:check(FugitiveHead() ==# 'main', 'fugitive: branch detected', FugitiveHead())
call setline(2, 'CHANGED')
silent write
let g:gitgutter_async = 0
call gitgutter#process_buffer(bufnr(''), 1)
let s:sum = GitGutterGetHunkSummary()
call s:check(s:sum == [0, 1, 0], 'gitgutter: modified hunk detected', string(s:sum))
call s:check(my#statusline#git() =~# 'main' && my#statusline#git() =~# '\~1', 'statusline git segment', my#statusline#git())
bwipeout!

" 7. Clipboard ───────────────────────────────────────────────────────────────
let s:prov = my#clip#provider()
call s:check(!empty(s:prov), 'clipboard provider found', s:prov)
if s:prov ==# 'xclip' || s:prov ==# 'wl'
  let s:token = 'vim-clip-test-' . localtime()
  call my#clip#copy(s:token)
  sleep 300m
  let s:back = my#clip#paste_text()
  call s:check(s:back ==# s:token, 'clipboard round-trip via ' . s:prov, string(s:back))
endif

" 8. Persistent undo ─────────────────────────────────────────────────────────
" Checked in two child Vims with this config: the first edits and writes, the
" second reopens the file and undoes. Root cause of the old silent stop here:
" in Ex/batch mode (vim -es) with 'lazyredraw' set, :undo waits for input and
" Vim exits on EOF — so the child turns lazyredraw off first. Interactive Vim
" is not affected.
call s:check(&undofile && isdirectory(expand('~/.vim/state/undo')), 'persistent undo configured')
let s:uf = tempname() . '.txt'
call writefile(['one'], s:uf)
let s:vim = 'vim -Nu ' . shellescape(expand('~/.vim/vimrc')) . ' -i NONE -es '
call system(s:vim . '-c ' . shellescape('call setline(1, "two") | silent write | qa!') . ' ' . shellescape(s:uf))
call system(s:vim . '-c ' . shellescape('set nolazyredraw | silent undo | call writefile([getline(1)], "' . s:uf . '.out") | qa!') . ' ' . shellescape(s:uf))
let s:back = filereadable(s:uf . '.out') ? readfile(s:uf . '.out') : ['<no output>']
call s:check(readfile(s:uf) ==# ['two'] && s:back ==# ['one'], 'persistent undo survives a Vim restart', string(s:back))

" 9. Editing behaviour ───────────────────────────────────────────────────────
let s:pyf = tempname() . '.py'
call writefile(['def f():', '    return 1   '], s:pyf)
execute 'edit ' . s:pyf
call s:check(&shiftwidth == 4 && &expandtab && &textwidth == 79, 'python: sw=4 et tw=79')
call s:check(&listchars =~# 'leadmultispace:│   ', 'indent guides follow shiftwidth', &listchars)
call s:check(!empty(filter(getmatches(), 'v:val.group ==# "ExtraWhitespace"')), 'trailing whitespace highlighted')
silent write
call s:check(getline(2) ==# '    return 1', 'trim trailing whitespace on save (python)', string(getline(2)))
bwipeout!
let s:gof = tempname() . '.go'
execute 'edit ' . s:gof
call s:check(!&expandtab, 'go: tabs (noexpandtab)')
bwipeout!
call s:check(maparg('<CR>', 'i') =~# 'my#complete#cr', 'insert <CR> = completion-aware lexima newline', maparg('<CR>', 'i'))
call s:check(exists('*lexima#expand'), 'lexima rules loaded at startup')

" 10. LSP ────────────────────────────────────────────────────────────────────
for s:srv in ['pyright-langserver', 'typescript-language-server', 'bash-language-server', 'yaml-language-server', 'gopls', 'clangd']
  let s:path = lsp_settings#exec_path(s:srv)
  call s:check(!empty(s:path) && executable(s:path), 'LSP server installed: ' . s:srv, fnamemodify(s:path, ':~'))
endfor
call s:check(g:lsp_use_native_client == 1, 'vim-lsp uses native LSP channel')

" 11. Large files ────────────────────────────────────────────────────────────
let s:big = tempname() . '.txt'
call writefile(repeat([repeat('x', 1000)], 2200), s:big)
execute 'edit ' . s:big
call s:check(get(b:, 'my_large_file', 0) && !&undofile && &syntax ==# 'OFF', 'large file (2.2 MB) opens in lean mode')
bwipeout!

" 12. Docs ───────────────────────────────────────────────────────────────────
let s:readme = expand('~/.vim/docs/GUIDE.md')
if filereadable(s:readme)
  let s:text = join(readfile(s:readme), "\n")
  let s:undoc = []
  for s:e in filter(copy(g:my_keys), 'v:val.wk !=# "which_key_ignore"')
    if stridx(s:text, '`' . escape(my#keys#pretty(s:e.lhs), '|') . '`') < 0
      call add(s:undoc, s:e.lhs)
    endif
  endfor
  call s:check(empty(s:undoc), 'README documents every registry entry (' . len(g:my_keys) . ')', join(s:undoc[:15], ', '))
  let s:gen = my#keys#markdown()
  let s:lines = readfile(s:readme)
  let s:b = index(s:lines, '<!-- KEYMAP:BEGIN (generated by :KeymapMarkdown — do not edit by hand) -->')
  let s:e = index(s:lines, '<!-- KEYMAP:END -->')
  call s:check(s:b >= 0 && s:lines[s:b + 1 : s:e - 2] ==# s:gen, 'README shortcut tables match the live registry exactly')
  let s:thin = map(filter(copy(g:my_keys), 'v:val.wk !=# "which_key_ignore" && (empty(my#keys#docs(v:val)[0]) || empty(my#keys#docs(v:val)[1]))'), 'v:val.modes . ":" . v:val.lhs')
  call s:check(empty(s:thin), 'every documented key has a description and an example', join(s:thin, ', '))
  let s:ids = {}
  for s:e in g:my_keys | let s:ids[s:e.cat . '|' . s:e.modes . '|' . s:e.lhs] = 1 | endfor
  let s:orphans = filter(keys(my#keydocs#get()), '!has_key(s:ids, v:val)')
  call s:check(empty(s:orphans), 'no orphaned entries in autoload/my/keydocs.vim', join(s:orphans, ', '))
else
  call s:check(0, 'README exists')
endif

" 13. Help guide, health report, theme preview ───────────────────────────────
for s:t in split(my#help#topics(), "\n")
  execute 'Guide ' . s:t
  call s:check(&filetype ==# 'myguide' && line('$') > 8 && get(b:, 'my_guide_topic', '') ==# s:t, ':Guide ' . s:t . ' renders', line('$') . ' lines')
endfor
call s:check(maparg('2', 'n') =~# 'show' && maparg('q', 'n') =~# 'close', ':Guide buffer keys (topics, q)')
close
call s:check(maparg('<leader>hc', 'n') =~# 'Guide', '<Space>hc opens the guide')
let s:h = my#health#lines()
call s:check(len(s:h) > 40 && empty(filter(copy(s:h), 'v:val =~# "^  ✘"')), 'health report: nothing required is missing', join(filter(copy(s:h), 'v:val =~# "^  ✘"'), ' | '))
call s:check(!empty(filter(copy(s:h), 'v:val =~# "AI assistant"')), 'health report covers the AI assistant')
" Raw :colorscheme of a managed scheme gets its own palette (not the previous one).
colorscheme catppuccin_mocha
call s:check(g:my_theme ==# 'dark' && synIDattr(synIDtrans(hlID('Normal')), 'bg#') ==? '#1e1e2e', 'raw :colorscheme catppuccin_mocha uses the Mocha palette')
colorscheme catppuccin_frappe
call s:check(synIDattr(synIDtrans(hlID('Normal')), 'bg#') ==? '#303446', 'unmanaged scheme keeps its own colours', synIDattr(synIDtrans(hlID('Normal')), 'bg#'))
Theme
call s:check(g:my_theme ==# 'space' && g:colors_name ==# 'space-vim-dark', ':Theme restores the default theme')
call s:check(exists(':ThemePreview') == 2 && maparg('<leader>tp', 'n') =~# 'ThemePreview', 'theme preview command and key')
for s:f in ['README.md', 'LICENSE', '.gitignore', 'vimrc', 'docs/GUIDE.md']
  call s:check(filereadable(expand('~/.vim/' . s:f)), 'repository file present: ' . s:f)
endfor

catch
  call s:check(0, 'test suite crashed', v:exception . ' @ ' . v:throwpoint)
endtry

" ── Report ──────────────────────────────────────────────────────────────────
call add(s:results, '')
call add(s:results, printf('%d checks, %d failed', len(s:results) - 1, s:fails))
call writefile(s:results, get(g:, 'my_test_out', '/dev/stdout'))
execute (s:fails ? 'cquit' : 'qall!')
