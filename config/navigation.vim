" ==============================================================================
"  navigation.vim — fuzzy finding (fzf), project search (ripgrep), explorer (fern)
" ==============================================================================

" ── fzf ───────────────────────────────────────────────────────────────────────
let g:my_has_fzf = my#core#has('fzf.vim') && executable('fzf')

if g:my_has_fzf
  " File source: fd → rg → find. All respect .gitignore and skip heavy dirs.
  if executable('fd')
    let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --strip-cwd-prefix'
          \ . ' --exclude .git --exclude node_modules --exclude __pycache__ --exclude .venv --exclude .mypy_cache'
  elseif executable('rg')
    let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git" --glob "!node_modules"'
  endif

  " Look & feel (scoped to fzf processes started from Vim; your shell's
  " FZF_DEFAULT_OPTS, if any, is kept and extended).
  let $FZF_DEFAULT_OPTS = $FZF_DEFAULT_OPTS
        \ . ' --layout=reverse --info=inline-right --cycle --scroll-off=4'
        \ . ' --prompt="❯ " --pointer="▌" --marker="▍" --separator="─" --scrollbar="▐"'
        \ . ' --bind=ctrl-/:toggle-preview,alt-a:select-all,alt-d:deselect-all,ctrl-u:half-page-up,ctrl-d:half-page-down'

  " Centered floating window with a rounded border.
  let g:fzf_layout = { 'window': {
        \ 'width': 0.88, 'height': 0.82, 'border': 'rounded', 'highlight': 'FloatBorder' } }

  " Colours come from the current highlight groups → always match the theme.
  let g:fzf_colors = {
        \ 'fg':        ['fg', 'Normal'],
        \ 'bg':        ['bg', 'Pmenu'],
        \ 'hl':        ['fg', 'Function'],
        \ 'fg+':       ['fg', 'Normal'],
        \ 'bg+':       ['bg', 'PmenuSel'],
        \ 'hl+':       ['fg', 'Statement'],
        \ 'info':      ['fg', 'Comment'],
        \ 'border':    ['fg', 'FloatBorder'],
        \ 'separator': ['fg', 'FloatBorder'],
        \ 'scrollbar': ['fg', 'PmenuThumb'],
        \ 'prompt':    ['fg', 'Function'],
        \ 'pointer':   ['fg', 'Statement'],
        \ 'marker':    ['fg', 'String'],
        \ 'spinner':   ['fg', 'Label'],
        \ 'header':    ['fg', 'Comment'],
        \ 'gutter':    ['bg', 'Pmenu'],
        \ 'query':     ['fg', 'Normal'] }

  " Inside any fzf list:
  "   <CR> open · <C-s> split · <C-v> vsplit · <C-t> tab · <C-q> → quickfix
  "   <Tab> mark multiple · <C-/> toggle preview
  let g:fzf_action = {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
        \ 'ctrl-q': function('my#find#to_quickfix') }

  let g:fzf_vim = {
        \ 'preview_window': ['right,55%,<60(down,45%)', 'ctrl-/'],
        \ 'buffers_jump': 1 }

  " Project-aware commands built on fzf.vim
  command! -bang ProjectFiles call my#find#project_files(<bang>0)
  command! -nargs=* -bang GrepWord call my#find#grep_word(<q-args>, <bang>0)
  command! -bang DirFiles call fzf#vim#files(expand('%:p:h'), fzf#vim#with_preview(), <bang>0)
endif

" ── fern (file explorer) ──────────────────────────────────────────────────────
let g:my_has_fern = my#core#has('vim-fern')
if g:my_has_fern
  let g:fern#renderer = g:my_icons && my#core#has('vim-fern-renderer-nerdfont') ? 'nerdfont' : 'default'
  let g:fern#renderer#nerdfont#indent_markers = 1
  let g:fern#renderer#default#leading = '  '
  let g:fern#renderer#default#collapsed_symbol = '▸ '
  let g:fern#renderer#default#expanded_symbol  = '▾ '
  let g:fern#renderer#default#leaf_symbol      = '  '
  let g:fern#disable_default_mappings   = 1          " curated set below
  let g:fern#disable_drawer_smart_quit  = 1          " replaced by my#fern#quit_pre() (see below)
  let g:fern#drawer_width               = get(g:, 'my_explorer_width', 30)
  let g:fern#hide_cursor                = 0
  let g:fern#default_hidden             = 0          " dotfiles hidden; toggle with  !
  " Ignore list for the tree (toggle the filter with  I  in the tree).
  let g:my_fern_exclude = '^\%(\.git\|data\|__pycache__\|.*\.pyc\|.*\~\|.*\.egg-info\|build\|_build.*'
        \ . '\|dist\|.*\.so\|.*\.o\|obj.*\|node_modules\|package-lock\.json\|.*\.gcno\|.*\.gcda'
        \ . '\|.*\.gcov\|dist-newstyle\|cabal\.project\.local\|\.mypy_cache\|\.pytest_cache\|\.venv\)$'
  let g:fern#default_exclude = g:my_fern_exclude
  let g:fern_git_status#disable_ignored    = 1      " faster on big repos
  let g:fern_git_status#disable_submodules = 1

  augroup my_fern
    autocmd!
    autocmd FileType fern call my#fern#setup()
    " vim -R / view: Vim marks buffers read-only *after* fern has loaded the
    " tree, so its next redraw would hit W10. The tree is never a file anyway.
    autocmd BufWinEnter,BufEnter fern://* setlocal noreadonly
  augroup END

  " IDE-style sidebar: opens by itself on startup (NERDTree-like), cursor stays
  " in the editor. Skipped for batch/Ex mode, stdin, diff, git commit
  " messages, temp files… — see my#fern#skip_reason(). Off switch:
  "   let g:my_explorer_autostart = 0     (~/.vim/local.vim)
  let g:my_explorer_autostart = get(g:, 'my_explorer_autostart', 1)
  augroup my_fern_sidebar
    autocmd!
    autocmd StdinReadPre * let g:my_stdin = 1
    " ++nested: the tree's FileType/BufEnter autocmds (keys, icons, statusline) must run.
    autocmd VimEnter * ++nested call my#dashboard#autostart() | call my#fern#autostart()
    autocmd SessionLoadPost * ++nested call my#fern#session_loaded()
    " :q in the last editor window closes the sidebar with it (never leaves a lone tree).
    autocmd QuitPre * call my#fern#quit_pre()
    autocmd WinClosed * call timer_start(0, {-> my#fern#after_win_closed()})
  augroup END
else
  " netrw fallback: tree style, no banner.
  let g:netrw_banner = 0
  let g:netrw_liststyle = 3
  let g:netrw_winsize = 22
endif

" ── Built-in navigation helpers ───────────────────────────────────────────────
" :find searches the project (used by the no-fzf fallbacks).
set path=.,,**
