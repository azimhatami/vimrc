" ==============================================================================
"  my#help — :Guide, the in-editor help hub (Space h c)
"
"  One scratch window with an index and topic pages. Static pages are plain
"  lists below; "live" pages (shortcuts, plugins, languages, health) are built
"  from the running configuration, so they cannot drift from reality.
"    :Guide            index            :Guide keys      cheat sheet
"    :Guide themes     theme controls   :Guide ai        AI assistant status
" ==============================================================================

" [key, topic, title, summary]
let s:topics = [
      \ ['1', 'start',     'Start here',        'the keys worth learning first'],
      \ ['2', 'keys',      'All shortcuts',     'every custom key, grouped (cheat sheet)'],
      \ ['3', 'features',  'Features',          'what this setup can do, area by area'],
      \ ['4', 'workflows', 'Workflows',         'open a project, search, edit, git, run tests'],
      \ ['5', 'themes',    'Themes',            'switch, preview, restore, customise'],
      \ ['6', 'languages', 'Languages & tools', 'servers, formatters, what is missing (live)'],
      \ ['7', 'plugins',   'Plugins',           'installed / loaded / on demand (live)'],
      \ ['8', 'ai',        'AI assistant',      'status, options, recommendation'],
      \ ['9', 'vim',       'Vim essentials',    'built-in commands worth knowing'],
      \ ['0', 'health',    'Health check',      'what works, what is missing (live)'],
      \ ]

let s:pages = {}

let s:pages.start = [
      \ 'Start here',
      \ '',
      \ '  The leader key is Space. Press Space and wait half a second: a menu',
      \ '  lists every group (f find, g git, l LSP, r run, t toggles, h help …).',
      \ '',
      \ '  Open things',
      \ '    Space Space      find a file in the project (fuzzy)',
      \ '    Space /          search text in the whole project',
      \ '    Space f r        recently opened files',
      \ '    Space e          show / hide the file explorer   (Space E: reveal this file)',
      \ '    Space b b        switch between open files       (Space 1 … 9: by number)',
      \ '',
      \ '  Edit',
      \ '    u  /  Ctrl-r     undo / redo                     (Space u: undo history tree)',
      \ '    Space c c        comment / uncomment line or selection',
      \ '    Space c f        format the file',
      \ '    Ctrl-s           save                            (Space s s also saves)',
      \ '    Space y / p      copy selection to / paste from the system clipboard',
      \ '',
      \ '  Understand code   (needs a language server — see topic 6)',
      \ '    gd               go to definition                (Ctrl-o comes back)',
      \ '    K                documentation of the symbol under the cursor',
      \ '    gr               list every reference',
      \ '    Space c r        rename a symbol everywhere',
      \ '',
      \ '  Git, terminal, run',
      \ '    Space g g        git status window (s stage, u unstage, cc commit)',
      \ '    F12              floating terminal (F12 again hides it)',
      \ '    Space r r        run the current file',
      \ '',
      \ '  When lost',
      \ '    Space h c        this guide            Space h h   health check',
      \ '    Space h k        search every mapping  Space h t   search Vim help',
      \ '    Esc              back to Normal mode   :q          close a window',
      \ ]

let s:pages.features = [
      \ 'Features',
      \ '',
      \ '  Status words: [works] tested on the development machine · [partial] works with a',
      \ '  limit that is stated · [needs X] an external program is not installed.',
      \ '',
      \ '  File navigation',
      \ '    File explorer (fern)        Space e · opens at startup        [works]',
      \ '    Reveal current file         Space E                           [works]',
      \ '    Fuzzy file search (fzf)     Space Space · Space f f / f g     [works]',
      \ '    Project text search (rg)    Space / · Space f w (word)        [works]',
      \ '    Recent files / projects     Space f r · dashboard lists       [works]',
      \ '    Buffers                     Space b b · Space 1…9 · ]b [b     [works]',
      \ '    Change directory            gc in the explorer · :cd          [works]',
      \ '',
      \ '  Editing',
      \ '    Persistent undo + tree      u / Ctrl-r · Space u              [works]',
      \ '    Surround                    ys cs ds · S in Visual            [works]',
      \ '    Comments                    Space c c · gc{motion}            [works]',
      \ '    Auto-close brackets/tags    automatic (lexima, closetag)      [works]',
      \ '    Search & replace            Space s r · live :s preview       [works]',
      \ '    Text objects                ia aa (args) · ih (hunk) · ie     [works]',
      \ '    Windows / tabs              Space w … · Ctrl-h/j/k/l          [works]',
      \ '    Folding (by indent)         Space z · za zR zM                [works]',
      \ '    System clipboard            Space y / p · yank sync           [works] via xclip',
      \ '    Format on save              prettier projects, Go, trim C/Py  [partial] Python: trim only',
      \ '',
      \ '  Code intelligence (LSP)',
      \ '    Completion while typing     Tab / S-Tab · Enter accepts       [works]',
      \ '    Definition / references     gd · gr · Space l …               [works]',
      \ '    Rename / code actions       Space c r · Space c a             [works]',
      \ '    Hover docs / signatures     K · automatic while typing        [works]',
      \ '    Diagnostics                 signs + inline · ]d [d            [works]',
      \ '    Symbol outline              Space l o (Vista)                 [works]',
      \ '    Snippets                    Ctrl-j expand/next · Ctrl-k back  [works]',
      \ '',
      \ '  Git',
      \ '    Status / commit / push      Space g g · g c · g p             [works]',
      \ '    Diff / blame / log          Space g d · g b · g B · g l       [works]',
      \ '    Hunks                       ]h [h · Space g s / g u / g h     [works]',
      \ '    Signs, branch in status line                                  [works]',
      \ '',
      \ '  Terminal & running code',
      \ '    Floating terminal           F12 · Space t F                   [works]',
      \ '    Terminal panel              Space t t                         [works]',
      \ '    Run file                    Space r r (py sh js ts go c cpp)  [works] ts needs npx/tsx',
      \ '    pytest                      Space r t / r f / r T             [needs pytest] in the project venv',
      \ '    make → quickfix             Space r m · r k picks a target    [works]',
      \ '    Re-run last command         Space r l                         [works]',
      \ '',
      \ '  Productivity',
      \ '    Dashboard                   vim with no file · Space b h      [works]',
      \ '    Sessions (per directory)    Space q s / q l / q d             [works]',
      \ '    Key menu (which-key)        Space, then wait                  [works]',
      \ '    Health check                Space h h                         [works]',
      \ '    Zen mode                    Space t z                         [works]',
      \ '',
      \ '  Topic 6 lists language support in detail; topic 8 covers AI.',
      \ ]

let s:pages.workflows = [
      \ 'Workflows',
      \ '',
      \ '  Open a project',
      \ '    cd ~/code/app && vim         explorer on the left, dashboard on the right',
      \ '    press a number / letter      open a recent file or switch to a project',
      \ '    Space q s  …  Space q l      save the window layout, restore it tomorrow',
      \ '',
      \ '  Find and replace across the project',
      \ '    Space /  type the text       live results with preview',
      \ '    Alt-a, then Ctrl-q           send every hit to the quickfix list',
      \ '    :cfdo %s/old/new/gc | update replace in each file, confirming each match',
      \ '',
      \ '  Rename something safely',
      \ '    cursor on the name, Space c r, type the new name   (language server)',
      \ '    no server? Space s r replaces the word in this file with confirmation',
      \ '',
      \ '  Review and commit',
      \ '    ]h / [h                      walk through your changes',
      \ '    Space g h / g s / g u        preview / stage / undo one hunk',
      \ '    Space g g                    status: s stage, = diff, cc commit',
      \ '    Space g p                    push',
      \ '',
      \ '  Fix errors in a file',
      \ '    ]d / [d                      next / previous diagnostic',
      \ '    Space c a                    quick fix offered by the server',
      \ '    Space l e                    all problems of the file as a list',
      \ '',
      \ '  Test loop (Python)',
      \ '    Space r t                    run the test under the cursor',
      \ '    edit …  Space r l            save and re-run the same command',
      \ '    Space r v, then Space r c    coverage run, highlight uncovered lines',
      \ '',
      \ '  Build loop (C / Makefile)',
      \ '    Space r m                    make; errors land in the quickfix list',
      \ '    ]q / [q                      jump from error to error',
      \ '',
      \ '  Use a snippet',
      \ '    type its name (main, test, for …) and press Ctrl-j; Ctrl-j again',
      \ '    moves to the next field. Space c s edits your own snippets.',
      \ ]

let s:pages.themes = [
      \ 'Themes',
      \ '',
      \ '  Default: Space Vim Dark. Nothing below changes',
      \ '  the default unless you edit ~/.vim/local.vim.',
      \ '',
      \ '  Keys',
      \ '    Space t p        preview: pick from a list, colours change as you',
      \ '                     move; Enter keeps it for this session, Esc restores',
      \ '    Space t B        cycle  Space Vim Dark → Catppuccin Mocha → Latte',
      \ '    Space t b        dark ↔ light (Catppuccin Latte) and back',
      \ '    Space t R        restore the default theme',
      \ '    :Theme dark      switch by name: space · dark (Mocha) · light (Latte)',
      \ '',
      \ '  Installed',
      \ '    Space Vim Dark       default · three backgrounds (default/darker/darkest)',
      \ '    Catppuccin Mocha     dark alternative, fully styled',
      \ '    Catppuccin Latte     light alternative, fully styled',
      \ '    Catppuccin Frappé / Macchiato    installed, syntax colours only',
      \ '    25 schemes built into Vim (habamax, sorbet, retrobox, slate …)',
      \ '                         load fine; the status line keeps the last palette',
      \ '',
      \ '  Make a choice permanent — ~/.vim/local.vim (copy local.vim.example)',
      \ "    let g:my_theme = 'dark'               \" space | dark | light",
      \ "    let g:my_space_background = 'darker'  \" default | darker | darkest",
      \ '    let g:my_transparent = 1              " terminal background shows through',
      \ '',
      \ '  Change individual colours — put this in ~/.vim/local.vim',
      \ '    augroup my_local_colors',
      \ '      autocmd!',
      \ '      autocmd ColorScheme * highlight Comment guifg=#7a8a99 gui=NONE',
      \ '      autocmd ColorScheme * highlight StartifyHeader guifg=#bc6ec5',
      \ '    augroup END',
      \ '    Groups: Normal, Comment, LineNr, CursorLine, Visual, Pmenu (pop-ups),',
      \ '    FernRootText / FernBranchText (explorer), StartifyHeader / StartifySection',
      \ '    (dashboard), WhichKey*, GitGutter*, Lsp*Text (diagnostics).',
      \ '    :highlight GroupName shows a group; the whole palette lives in',
      \ '    autoload/my/ui.vim (status line: autoload/lightline/colorscheme/).',
      \ ]

let s:pages.ai = [
      \ 'AI assistant',
      \ '',
      \ '  Status: NOT INSTALLED. No AI plugin is active, nothing is sent anywhere',
      \ '  and no account or key is configured. Options checked for this Vim',
      \ '  (9.1, +python3, Node available, no GPU):',
      \ '',
      \ '  Solution           Inline  Chat  Edits  Local  Cost',
      \ '  Claude Code CLI    no      yes   yes*   no     existing Claude plan',
      \ '  GitHub Copilot     yes     no    no     no     free tier 2,000/month, or paid',
      \ '  vim-ai             no      yes   yes    opt.   pay per use (API key)',
      \ '  vim-ollama         yes     yes   yes    yes    free; 1–5 GB model download',
      \ '  llama.vim          yes     no    no     yes    free; ~1 GB model download',
      \ '  windsurf / augment / supermaven: archived, completion removed or Neovim-only',
      \ '    * every edit is shown as a diff and needs your approval',
      \ '',
      \ '  Recommendation',
      \ '    1. Claude Code in a Vim terminal for questions, explanations, reviews,',
      \ '       tests and refactoring. It is already installed here; try it now:',
      \ '         F12, then type:  claude',
      \ '       Files it changes reload in Vim automatically (autoread).',
      \ '    2. Add github/copilot.vim only if you want suggestions while typing.',
      \ '       It needs a GitHub sign-in and sends nearby code to GitHub.',
      \ '    A local model is private but slow on a CPU-only machine (seconds per',
      \ '    suggestion) and clearly weaker.',
      \ '',
      \ '  Rules this configuration follows',
      \ '    no key in any tracked file · no cloud plugin without your sign-in',
      \ '    no automatic model downloads · AI edits must be reviewable',
      \ '',
      \ '  Details and setup steps: docs/GUIDE.md › AI assistant  (Space h r)',
      \ ]

let s:pages.vim = [
      \ 'Vim essentials (built in, no plugin)',
      \ '',
      \ '  Modes      i insert · v select · V lines · Ctrl-v block · Esc normal · : command',
      \ '  Move       w b e words · 0 ^ $ line · gg G file · { } paragraph · % pair',
      \ '             Ctrl-d / Ctrl-u half page · Ctrl-o / Ctrl-i back / forward in jumps',
      \ '             f x / t x jump to character · * search word under cursor',
      \ '  Change     d delete · c change · y yank · p paste, combined with a motion:',
      \ '             dw  ciw  yap  dd  cc  yy   ·   . repeats the last change',
      \ '             ci" ci( cit  change inside quotes / brackets / tag',
      \ '  Search     /text  ?text  n N · :%s/old/new/gc replace with confirmation',
      \ '             :g/pat/d delete matching lines · :v/pat/d delete the others',
      \ '  Files      :e file · :w · :wa · :q · :qa · :e! reload · :saveas',
      \ '             :Rename :Move :Delete :Mkdir :Chmod  (vim-eunuch)',
      \ '  Windows    :sp :vs · Ctrl-w o only this · Ctrl-w = equal · Ctrl-w T to a tab',
      \ '  Buffers    :ls · :b name · Ctrl-^ alternate',
      \ '  Marks      ma set · `a jump · `. last change · `` previous position',
      \ '  Registers  "ay yank into a · "ap paste a · :reg list · Ctrl-r a in insert',
      \ '  Macros     qq … q record · Q replay (this config) · 10Q ten times',
      \ '  Folds      za toggle · zR open all · zM close all · zj zk next / previous',
      \ '  Quickfix   :copen · ]q [q · :cdo cmd · :Cfilter /pat/',
      \ '  Spelling   Space t s · ]s next · z= suggestions · zg add word',
      \ '  Help       :help topic · Ctrl-] follow link · Space h t fuzzy help',
      \ ]

" ── Live pages ────────────────────────────────────────────────────────────────
function! s:page_keys() abort
  return my#keys#cheatsheet_lines()
endfunction

function! s:page_plugins() abort
  let l:L = ['Plugins (vim-plug) — live state of this session', '',
        \ '  loaded  = on the runtime path now · lazy = loads on first use (trigger shown)',
        \ '  Update: Space h u (snapshot first) · Status: Space h p · Lockfile: plug-snapshot.vim', '']
  let l:rtp = map(split(&runtimepath, ','), 'fnamemodify(v:val, ":p")')
  let [l:n, l:nl] = [0, 0]
  for l:name in sort(keys(get(g:, 'plugs', {})))
    let l:p = g:plugs[l:name]
    let l:here = isdirectory(l:p.dir)
    let l:in = index(l:rtp, fnamemodify(l:p.dir, ':p')) >= 0
    let l:trig = has_key(l:p, 'on') ? 'on :' . join(type(l:p.on) == v:t_list ? l:p.on : [l:p.on], ' :')
          \ : has_key(l:p, 'for') ? 'for ' . join(type(l:p.for) == v:t_list ? l:p.for : [l:p.for], ', ') : ''
    let l:state = !l:here ? 'MISSING' : l:in ? 'loaded' : 'lazy'
    let l:n += l:here | let l:nl += l:in
    call add(l:L, printf('  %-8s %-30s %s', l:state, l:name, l:trig))
  endfor
  call insert(l:L, printf('  %d declared · %d installed · %d loaded now', len(get(g:, 'plugs', {})), l:n, l:nl), 2)
  call extend(l:L, ['', '  What each plugin is for: docs/GUIDE.md › Plugin guide  (Space h r)'])
  return l:L
endfunction

function! s:has(cmd) abort
  return executable(a:cmd) ? 'found' : 'NOT installed'
endfunction

function! s:srv(name) abort
  return exists('*lsp_settings#exec_path') && !empty(lsp_settings#exec_path(a:name)) ? 'installed' : 'NOT installed'
endfunction

function! s:page_languages() abort
  let l:pr = executable(expand('~/.vim/plugged/vim-prettier/node_modules/.bin/prettier', 1)) ? 'bundled' : s:has('prettier')
  return ['Languages & tools — checked just now', '',
        \ '  Python',
        \ '    server      pyright-langserver: ' . s:srv('pyright-langserver') . ' (completion, gd, rename, diagnostics)',
        \ '    formatter   ruff ' . s:has('ruff') . ' · black ' . s:has('black') . ' · autopep8 ' . s:has('autopep8'),
        \ '                (also looked up in the project virtualenv; without one, Space c f only re-indents)',
        \ '    tests       python -m pytest from .venv / venv / $VIRTUAL_ENV, else system python3',
        \ '    interpreter ' . fnamemodify(my#run#python(), ':~'),
        \ '  JavaScript / TypeScript',
        \ '    server      typescript-language-server: ' . s:srv('typescript-language-server'),
        \ '                starts only inside a project (package.json, tsconfig.json, jsconfig.json or node_modules)',
        \ '    formatter   prettier: ' . l:pr . ' (on save only in projects with a prettier config)',
        \ '  Svelte        syntax, prettier, tag closing — no language server configured',
        \ '  HTML / CSS / JSON / Markdown   prettier + Vim syntax — no language server configured',
        \ '  C / C++',
        \ '    server      clangd: ' . s:srv('clangd') . ' (also formats: Space c f) · compiler gcc ' . s:has('gcc'),
        \ '  Shell',
        \ '    server      bash-language-server: ' . s:srv('bash-language-server') . ' (gd, rename, completion)',
        \ '    linting     shellcheck ' . s:has('shellcheck') . ' — without it the server reports no warnings',
        \ '    formatter   shfmt ' . s:has('shfmt'),
        \ '  YAML          yaml-language-server: ' . s:srv('yaml-language-server') . ' (schemas, validation, formatting)',
        \ '  Go            gopls: ' . s:srv('gopls') . ' · go ' . s:has('go') . ' · gofmt on save through gopls',
        \ '  Haskell       indentation settings only — no server, no formatter',
        \ '  Vim script    indentation settings; Space r r sources the file',
        \ '',
        \ '  Add a server: open a file of that language, then Space l I  (:LspInstallServer)',
        \ '  This buffer:  Space l x shows which server is attached',
        \ ]
endfunction

function! s:index() abort
  let l:L = ['Vim guide', '',
        \ '  Press the key in front of a topic.  - returns here · / searches · q closes', '']
  for [l:k, l:_, l:title, l:sum] in s:topics
    call add(l:L, printf('    %s   %-20s %s', l:k, l:title, l:sum))
  endfor
  call extend(l:L, ['', '    o   Full guide           docs/GUIDE.md in a split (also Space h r)',
        \ '', '  Space on its own (then wait) shows the key menu at any time.'])
  return l:L
endfunction

function! s:lines(topic) abort
  if a:topic ==# 'index'     | return s:index() | endif
  if a:topic ==# 'keys'      | return s:page_keys() | endif
  if a:topic ==# 'plugins'   | return s:page_plugins() | endif
  if a:topic ==# 'languages' | return s:page_languages() | endif
  if a:topic ==# 'health'    | return my#health#lines() | endif
  return map(copy(get(s:pages, a:topic, s:index())), '(v:key == 0 ? "" : "") . v:val')
endfunction

function! my#help#topics(...) abort
  return join(['index'] + map(copy(s:topics), 'v:val[1]'), "\n")
endfunction

function! s:show(topic) abort
  let l:topic = a:topic ==# 'index' || !empty(filter(copy(s:topics), 'v:val[1] ==# a:topic')) ? a:topic : 'index'
  setlocal modifiable
  silent call deletebufline('%', 1, '$')
  call setline(1, s:lines(l:topic))
  setlocal nomodifiable
  let b:my_guide_topic = l:topic
  call cursor(1, 1)
endfunction

function! my#help#open(...) abort
  let l:topic = a:0 && !empty(a:1) ? a:1 : 'index'
  " Reuse the guide window when it is already open.
  let l:win = filter(range(1, winnr('$')), 'getbufvar(winbufnr(v:val), "&filetype") ==# "myguide"')
  if !empty(l:win)
    execute l:win[0] . 'wincmd w'
  else
    call my#find#main_window()
    botright vnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nonumber norelativenumber
    setlocal signcolumn=no nolist nowrap colorcolumn= filetype=myguide
    execute 'vertical resize ' . min([max([&columns / 2, 84]), 100, &columns - 20])
    let b:asyncomplete_enable = 0
    for [l:k, l:t, l:_, l:__] in s:topics
      execute 'nnoremap <buffer><silent><nowait> ' . l:k . ' :call <SID>show(' . string(l:t) . ')<CR>'
    endfor
    nnoremap <buffer><silent><nowait> -    :call <SID>show('index')<CR>
    nnoremap <buffer><silent><nowait> <BS> :call <SID>show('index')<CR>
    nnoremap <buffer><silent><nowait> o    :close <Bar> call my#find#main_window() <Bar> call my#health#readme()<CR>
    nnoremap <buffer><silent><nowait> q    :close <Bar> call my#find#main_window()<CR>
    syntax match GuideTitle /\%1l.*/
    syntax match GuideHead /^  \u[^·]*$/
    syntax match GuideOk /\[works\]/
    syntax match GuideWarn /\[partial\]\|\[needs [^\]]*\]\|NOT installed\|NOT INSTALLED\|MISSING/
    syntax match GuideKey /^    \zs\S\+\%( \S\+\)\{,3}\ze\s\{2,}/
    syntax match GuideMode /^    \[\w\+\]/
    syntax match GuideMark /^  [✔✘!·–]/
    highlight default link GuideTitle Title
    highlight default link GuideHead Statement
    highlight default link GuideOk String
    highlight default link GuideWarn WarningMsg
    highlight default link GuideKey Identifier
    highlight default link GuideMode Comment
    highlight default link GuideMark Special
  endif
  call s:show(l:topic)
endfunction
