" ==============================================================================
"  my#health — :VimHealth report, plugin snapshots/updates, README helpers
" ==============================================================================

" a:state: 1 working · 0 missing/broken · -1 optional (absent, nothing breaks)
"          2 needs configuration · 3 not applicable
function! s:ok(state, label, detail) abort
  let l:mark = {1: '✔', 0: '✘', -1: '·', 2: '!', 3: '–'}[a:state]
  return printf('  %s %-26s %s', l:mark, a:label, a:detail)
endfunction

function! s:ver(cmd) abort
  if !executable(split(a:cmd)[0]) | return 'not found' | endif
  return trim(get(systemlist(a:cmd . ' 2>&1'), 0, '?'))
endfunction

" First formatter found for Python: the project's virtualenv, then $PATH.
function! s:py_formatter() abort
  for l:exe in ['ruff', 'black', 'autopep8']
    let l:bin = fnamemodify(my#run#python(), ':h') . '/' . l:exe
    if executable(l:bin) || executable(l:exe) | return l:exe | endif
  endfor
  return ''
endfunction

function! my#health#lines() abort
  let l:L = []
  let l:plugs = get(g:, 'plugs', {})
  let l:rtp = map(split(&runtimepath, ','), 'fnamemodify(v:val, ":p")')
  call add(l:L, '  Vim configuration health — ' . strftime('%Y-%m-%d %H:%M'))
  call add(l:L, '  ✔ working   ✘ missing   · optional   ! needs configuration   – not applicable')
  call add(l:L, '')
  call add(l:L, '  Core')
  call add(l:L, s:ok(v:version >= 900, 'Vim', printf('%d.%d (patches %s)', v:version / 100, v:version % 100,
        \ matchstr(execute('version'), 'Included patches: \zs[^\n]*'))))
  call add(l:L, s:ok(empty(g:my_errors), 'Startup errors', empty(g:my_errors) ? 'none' : join(g:my_errors, ' | ')))
  call add(l:L, s:ok(exists('*plug#begin'), 'Plugin manager', exists('*plug#begin') ? 'vim-plug (autoload/plug.vim)' : 'vim-plug missing — built-in features only'))
  let l:missing = filter(keys(l:plugs), '!isdirectory(l:plugs[v:val].dir)')
  let l:loaded = len(filter(keys(l:plugs), 'index(l:rtp, fnamemodify(l:plugs[v:val].dir, ":p")) >= 0'))
  call add(l:L, s:ok(empty(l:missing), 'Plugins', len(l:plugs) . ' declared, ' . (len(l:plugs) - len(l:missing)) . ' installed, '
        \ . l:loaded . ' loaded now (the rest load on demand)' . (empty(l:missing) ? '' : ' — missing: ' . join(l:missing, ', ') . ' → :PlugInstall')))
  let l:snap = expand('~/.vim/plug-snapshot.vim')
  call add(l:L, s:ok(filereadable(l:snap) ? 1 : 2, 'Plugin lockfile', filereadable(l:snap) ? fnamemodify(l:snap, ':~') . ' (' . strftime('%Y-%m-%d', getftime(l:snap)) . ')' : 'missing — run :ConfigSnapshot'))
  call add(l:L, s:ok(1, 'Custom mappings', len(filter(copy(g:my_keys), 'v:val.kind ==# "map"')) . ' defined, ' . len(g:my_keys) . ' documented (Space h c)'))
  call add(l:L, s:ok(&undofile && isdirectory(&undodir[:-3]), 'Persistent undo', fnamemodify(&undodir[:-3], ':~')))
  let l:clip = my#clip#provider()
  call add(l:L, s:ok(!empty(l:clip), 'System clipboard', empty(l:clip) ? 'no provider (install xclip or wl-clipboard)' : l:clip . (has('clipboard') ? '' : ' (Vim built without +clipboard → bridged)')))
  call add(l:L, '')
  call add(l:L, '  Interface')
  call add(l:L, s:ok(exists('g:colors_name') && g:colors_name =~# 'catppuccin\|space-vim-dark', 'Colour scheme', my#ui#theme_name() . ' (' . get(g:, 'colors_name', 'none') . ', g:my_theme=' . g:my_theme . ') — preview others: Space t p'))
  call add(l:L, s:ok(&termguicolors ? 1 : 2, 'Terminal colours', &termguicolors ? 'true colour ($COLORTERM=' . $COLORTERM . ')' : '256-colour fallback (t_Co=' . &t_Co . '); themes are approximated'))
  call add(l:L, s:ok(g:my_icons ? 1 : -1, 'Nerd Font icons', g:my_icons ? 'on (font found in ~/.local/share/fonts; the terminal must use or fall back to it)' : 'off — plain Unicode symbols (tools/bootstrap.sh --font)'))
  call add(l:L, s:ok(my#core#has('lightline.vim'), 'Status / buffer line', my#core#has('lightline.vim') ? 'lightline + bufferline (my_palette)' : 'built-in fallback status line'))
  let l:fern = get(g:, 'my_has_fern', 0)
  call add(l:L, s:ok(l:fern, 'File explorer', l:fern ? 'fern' . (get(g:, 'my_explorer_autostart', 1) ? ', opens at startup' : ', autostart off') . (exists('*my#fern#drawer_winnr') && my#fern#drawer_winnr() ? ' — open now' : ' — closed now (Space e)') : 'vim-fern missing → netrw fallback'))
  let l:dash = get(g:, 'my_has_dashboard', 0)
  call add(l:L, s:ok(!l:dash ? 0 : g:my_dashboard ? 1 : -1, 'Dashboard', l:dash ? (g:my_dashboard ? 'on — last start: ' . (empty(get(g:, 'my_dashboard_skipped', '')) ? 'shown' : 'skipped (' . g:my_dashboard_skipped . ')') : 'off (g:my_dashboard = 0)') : 'vim-startify missing'))
  call add(l:L, s:ok(get(g:, 'my_has_fzf', 0), 'Fuzzy finder', get(g:, 'my_has_fzf', 0) ? 'fzf.vim + ' . s:ver('fzf --version') : 'fzf missing → :find / :grep fallbacks'))
  call add(l:L, s:ok(my#core#has('vim-which-key'), 'Key menu / help', (my#core#has('vim-which-key') ? 'which-key (press Space and wait)' : 'which-key missing') . ' · :Guide (Space h c)'))
  call add(l:L, '')
  call add(l:L, '  External commands')
  for [l:name, l:cmd, l:why, l:need] in [['git', 'git --version', 'fugitive, gitgutter', 1], ['fzf', 'fzf --version', 'fuzzy finder', 1],
        \ ['rg', 'rg --version', 'project grep (Space /)', 1], ['fd', 'fd --version', 'fast file listing', -1],
        \ ['node', 'node --version', 'npm-based language servers, prettier', 1],
        \ ['python3', 'python3 --version', 'Python runner', 1], ['xclip', 'xclip -version', 'clipboard (X11/XWayland)', -1],
        \ ['wl-copy', 'wl-copy --version', 'clipboard (Wayland)', -1], ['bat', 'bat --version', 'coloured fzf previews', -1],
        \ ['make', 'make --version', 'Space r m / r k', -1], ['gcc', 'gcc --version', 'C runner, make builds', -1],
        \ ['go', 'go version', 'Go runner', -1], ['shellcheck', 'shellcheck --version', 'shell diagnostics in bash-language-server', -1],
        \ ['ctags', 'ctags --version', 'not used (outline comes from LSP)', 3]]
    let l:v = s:ver(l:cmd)
    call add(l:L, s:ok(l:v !=# 'not found' ? 1 : l:need == 1 ? 0 : l:need, l:name, l:v . '  — ' . l:why))
  endfor
  call add(l:L, '')
  call add(l:L, '  Language servers  (~/.local/share/vim-lsp-settings/servers)')
  let l:running = exists('*lsp#get_allowed_servers') ? filter(lsp#get_allowed_servers(), 'lsp#get_server_status(v:val) ==# "running"') : []
  for [l:srv, l:ft] in [['pyright-langserver', 'python'], ['typescript-language-server', 'js/ts (needs package.json / tsconfig.json)'],
        \ ['bash-language-server', 'sh'], ['yaml-language-server', 'yaml'], ['gopls', 'go'], ['clangd', 'c/c++']]
    let l:path = exists('*lsp_settings#exec_path') ? lsp_settings#exec_path(l:srv) : ''
    call add(l:L, s:ok(empty(l:path) ? 2 : 1, l:srv, empty(l:path) ? 'not installed — :LspInstallServer in a ' . l:ft . ' file'
          \ : 'installed · ' . l:ft . (index(l:running, l:srv) >= 0 ? ' · RUNNING for this buffer' : '')))
  endfor
  call add(l:L, '    (a server starts when you open a file of its language; Space l x shows its state)')
  call add(l:L, s:ok(3, 'svelte / haskell', 'no language server configured (syntax + indentation only)'))
  call add(l:L, '')
  call add(l:L, '  Formatters, snippets, Python')
  let l:pf = s:py_formatter()
  call add(l:L, s:ok(empty(l:pf) ? 2 : 1, 'Python formatter', empty(l:pf) ? 'none found (ruff / black / autopep8) — Space c f only re-indents; install one in the project venv' : l:pf))
  let l:pr = expand('~/.vim/plugged/vim-prettier/node_modules/.bin/prettier', 1)
  call add(l:L, s:ok(executable(l:pr) ? 1 : executable('prettier') ? 1 : 2, 'prettier (web files)', executable(l:pr) ? 'bundled with vim-prettier' : executable('prettier') ? 'global' : 'not installed — run npm install in plugged/vim-prettier'))
  call add(l:L, s:ok(executable('shfmt') ? 1 : -1, 'shfmt (shell)', executable('shfmt') ? 'found' : 'not installed — shell files are re-indented by Vim'))
  call add(l:L, s:ok(1, 'gofmt / clang-format', 'provided by gopls / clangd through the language server'))
  let l:own = len(glob('~/.vim/snippets/*.json', 0, 1))
  call add(l:L, s:ok(my#core#has('vim-vsnip'), 'Snippets', my#core#has('vim-vsnip') ? 'vim-vsnip · ' . l:own . ' own files in ~/.vim/snippets' . (my#core#has('friendly-snippets') ? ' + friendly-snippets' : '') : 'vim-vsnip missing'))
  let l:py = my#run#python()
  call add(l:L, s:ok(l:py ==# 'python3' ? 3 : 1, 'Python virtualenv', l:py ==# 'python3' ? 'none for this directory → system python3 (pytest must be importable there)' : fnamemodify(l:py, ':~')))
  call add(l:L, '')
  call add(l:L, '  AI assistant')
  let l:ai = get(g:, 'my_ai', '')
  call add(l:L, s:ok(empty(l:ai) ? -1 : 1, 'AI assistant', empty(l:ai) ? 'not configured — options and recommendation: :Guide ai' : l:ai))
  call add(l:L, '')
  call add(l:L, '  q closes · :messages shows warnings · Space h c help · Space h r full guide')
  return l:L
endfunction

function! my#health#report() abort
  let l:L = my#health#lines()
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nonumber norelativenumber signcolumn=no nolist
  call setline(1, l:L)
  setlocal nomodifiable filetype=myhealth
  execute 'resize ' . min([len(l:L) + 1, &lines / 2 + 6])
  syntax match HealthOk /^  ✔/
  syntax match HealthBad /^  ✘/
  syntax match HealthCfg /^  !/
  syntax match HealthOpt /^  [·–].*$/
  syntax match HealthHead /^  \u[a-z].*$/
  syntax match HealthLegend /\%2l.*/
  highlight default link HealthOpt Comment
  highlight default link HealthLegend Comment
  highlight default HealthOk ctermfg=green guifg=#67b11d
  highlight default HealthBad ctermfg=red guifg=#ce537a
  highlight default HealthCfg ctermfg=yellow guifg=#d1951d
  highlight default link HealthHead Title
  nnoremap <buffer><silent><nowait> q :close <Bar> call my#find#main_window()<CR>
endfunction

" Write a vim-plug snapshot (exact commits) — the lockfile and a dated copy.
function! my#health#snapshot() abort
  let l:dir = expand('~/.vim/snapshots')
  if !isdirectory(l:dir) | call mkdir(l:dir, 'p') | endif
  let l:dated = l:dir . '/plug-' . strftime('%Y%m%d-%H%M%S') . '.vim'
  execute 'PlugSnapshot! ' . fnameescape(l:dated)
  silent! bwipeout
  " The lockfile is tracked in git: leave out vim-plug's local timestamp line.
  call writefile(filter(readfile(l:dated), 'v:val !~# ''^" \a\+ \d\+ \a\+ \d\{4} '''), expand('~/.vim/plug-snapshot.vim'))
  echo 'Snapshot → ' . fnamemodify(l:dated, ':~') . '  (restore: vim -S ' . fnamemodify(l:dated, ':~') . ')'
  return l:dated
endfunction

function! my#health#update_plugins() abort
  let l:snap = my#health#snapshot()
  echom 'Restore point: vim -S ' . fnamemodify(l:snap, ':~')
  PlugUpdate
endfunction

function! my#health#readme() abort
  execute 'botright vsplit ' . fnameescape(expand('~/.vim/docs/GUIDE.md'))
  setlocal readonly nomodifiable wrap linebreak
endfunction

" Regenerate the shortcut tables between the README markers.
function! my#health#keymap_markdown() abort
  let l:readme = expand('~/.vim/docs/GUIDE.md')
  let l:table = my#keys#markdown()
  if !filereadable(l:readme)
    new | call setline(1, l:table) | return
  endif
  let l:lines = readfile(l:readme)
  let l:s = index(l:lines, '<!-- KEYMAP:BEGIN (generated by :KeymapMarkdown — do not edit by hand) -->')
  let l:e = index(l:lines, '<!-- KEYMAP:END -->')
  if l:s < 0 || l:e < l:s
    echoerr 'README markers not found' | return
  endif
  call writefile(l:lines[: l:s] + l:table + [''] + l:lines[l:e :], l:readme)
  echo 'README shortcut tables regenerated (' . len(g:my_keys) . ' entries)'
endfunction
