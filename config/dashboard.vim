" ==============================================================================
"  dashboard.vim — start screen (vim-startify) shown beside the explorer
"
"  `vim` with no file arguments → explorer on the left, this dashboard on the
"  right: recent files of this project, recent files everywhere, recent
"  projects, saved sessions and a few commands. Opening anything replaces the
"  dashboard in place (its buffer is wiped); the explorer stays.
"
"  Never shown for `vim file`, `vim dir/`, `vim -` (stdin), `vim -S`, diff
"  mode, Ex/batch mode or git commit messages — see my#dashboard#skip_reason().
"  Off switch:  let g:my_dashboard = 0   (~/.vim/local.vim)
" ==============================================================================

let g:my_has_dashboard = my#core#has('vim-startify')
if !g:my_has_dashboard
  finish
endif

" Started by my#dashboard#autostart() (VimEnter, before the explorer opens),
" not by Startify itself — so the two never race for the window.
let g:startify_disable_at_vimenter = 1

" Lists. Indices: digits first, then letters that are free on this screen
" (e i q b s t v B S T V are Startify's own keys, j k n N move/search,
"  f g r l c h are the commands below).
let g:startify_custom_indices = map(range(10), 'string(v:val)')
      \ + ['a', 'd', 'm', 'o', 'p', 'u', 'w', 'x', 'y', 'z']
let g:startify_files_number = 6
let g:startify_lists = [
      \ { 'type': function('my#dashboard#project_recent'), 'header': ['    ' . my#dashboard#section('folder') . 'Recent in this project'] },
      \ { 'type': function('my#dashboard#recent'),   'header': ['    ' . my#dashboard#section('history') . 'Recent files elsewhere'] },
      \ { 'type': function('my#dashboard#projects'), 'header': ['    ' . my#dashboard#section('project') . 'Projects'] },
      \ { 'type': function('my#dashboard#sessions'), 'header': ['    ' . my#dashboard#section('session') . 'Sessions  (Space q s saves one)'] },
      \ { 'type': 'commands',                     'header': ['    ' . my#dashboard#section('command') . 'Commands'] },
      \ ]
let g:startify_commands = [
      \ {'f': ['Find file in project       Space Space', 'call my#dashboard#run("ProjectFiles")']},
      \ {'g': ['Search text in project    Space /', 'call my#dashboard#run("RG")']},
      \ {'r': ['Recent files (fuzzy)      Space f r', 'call my#dashboard#run("History")']},
      \ {'l': ['Restore this directory''s session', 'SessionLoad']},
      \ {'c': ['Edit configuration', 'call my#dashboard#config()']},
      \ {'h': ['Help, shortcuts, themes   Space h c', 'Guide']},
      \ ]

" Look
let g:startify_padding_left      = 4
let g:startify_custom_header     = 'my#dashboard#header()'
let g:startify_custom_footer     = 'my#dashboard#footer()'
let g:startify_enable_special    = 0      " no <empty buffer>/<quit> rows (e and q still work)
let g:startify_use_env           = 0
let g:startify_fortune_use_unicode = 1

" Behaviour: this config owns the working directory and sessions.
let g:startify_change_to_dir       = 0
let g:startify_change_to_vcs_root  = 0
let g:startify_change_cmd          = 'cd'
let g:startify_session_autoload    = 0
let g:startify_session_persistence = 0
let g:startify_session_dir         = g:my_state_dir . '/sessions'
let g:startify_update_oldfiles     = 1      " files you open now show up immediately
" One combined pattern: Startify tests every recent file against each list
" item, so a single regex is several times cheaper than ten.
let g:startify_skiplist = [join([
      \ 'COMMIT_EDITMSG$', 'MERGE_MSG$', 'git-rebase-todo$', '/\.git/',
      \ '^/tmp/', '^/var/tmp/', '^/dev/shm/',
      \ '^' . escape(fnamemodify(resolve($VIMRUNTIME), ':p'), '\.~[]*'),
      \ '/\.vim/plugged/.*/doc/', '/\.vim/state/'], '\|')]

augroup my_dashboard
  autocmd!
  autocmd User Startified call my#dashboard#setup()
  autocmd StdinReadPre * let g:my_stdin = 1
  " Normally started from navigation.vim's VimEnter (dashboard first, then
  " the explorer beside it). Without fern, start it from here.
  if !get(g:, 'my_has_fern', 0)
    autocmd VimEnter * ++nested call my#dashboard#autostart()
  endif
augroup END
