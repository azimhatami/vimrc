" ==============================================================================
"  mappings.vim — every custom key, defined AND documented in one place
"
"  Leader = <Space>.  Groups (press <Space> and wait to see them):
"    f find · b buffers · w windows · g git · c code · l lsp · r run/test
"    x lists · s save/substitute · t toggles · q quit/sessions · h help
"
"  Each line: call s:map(modes, lhs, rhs, action, {info, ex, cond, …})
"  The registry (my#keys) generates which-key, :Cheatsheet and the README.
" ==============================================================================

let s:map = function('my#keys#map')
let s:doc = function('my#keys#doc')
let s:fzf  = get(g:, 'my_has_fzf', 0)
let s:fern = get(g:, 'my_has_fern', 0)
let s:rg   = executable('rg')

" Don't let a bare <Space> move the cursor.
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>

for [s:k, s:t, s:s] in [['f', 'Find & search', 'find'], ['b', 'Buffers', 'buffers'], ['w', 'Windows & tabs', 'windows'],
      \ ['g', 'Git', 'git'], ['c', 'Code', 'code'], ['l', 'LSP & diagnostics', 'lsp'], ['r', 'Run & test', 'run/test'],
      \ ['x', 'Lists (quickfix)', 'lists'], ['s', 'Save & substitute', 'save'], ['t', 'Toggles & theme', 'toggles'],
      \ ['q', 'Quit & sessions', 'quit/session'], ['h', 'Help & health', 'help']]
  call my#keys#group(s:k, s:t, s:s)
endfor
unlet s:k s:t s:s

" ══ Quick access (single key after <Space>) ═══════════════════════════════════
call s:map('n', '<leader><Space>', s:fzf ? ':call my#find#main_window() <Bar> ProjectFiles<CR>' : ':call my#find#fallback_files()<CR>',
      \ 'Find project files', {'info': 'Git repo: tracked + untracked files; elsewhere: every file. Fuzzy, with preview.',
      \ 'ex': 'Space Space, type "authsrv" → src/auth/service.ts', 'cond': 'fzf'})
call s:map('n', '<leader>/', s:fzf && s:rg ? ':call my#find#main_window() <Bar> RG<CR>' : ':call my#find#fallback_grep()<CR>',
      \ 'Live grep project', {'info': 'ripgrep re-runs as you type (regex, smart-case); preview on the right.',
      \ 'ex': 'Find every "TODO(auth)" in the repo; <C-q> sends hits to quickfix', 'cond': 'fzf + ripgrep'})
call s:map('n', '<leader>e', s:fern ? ':call my#fern#toggle()<CR>' : ':Lexplore<CR>',
      \ 'Explorer (toggle)', {'info': 'Hide/show the project sidebar on the left (it opens by itself when Vim starts). Opening moves the cursor into it.', 'ex': 'Hide the tree for more room, bring it back to browse; press ? inside for keys'})
call s:map('n', '<leader>E', s:fern ? ':call my#fern#reveal()<CR>' : ':Lexplore %:p:h<CR>',
      \ 'Explorer: reveal file', {'info': 'Open/focus the sidebar with the cursor on the current file.', 'ex': 'Where does this file live?'})
call s:map('n', '<leader>u', ':UndotreeToggle<CR>', 'Undo tree',
      \ {'info': 'Visual undo history with diffs (history persists across restarts).', 'ex': 'Recover the version from 20 minutes ago'})
call s:map('n', '<leader>z', 'za', 'Toggle fold',
      \ {'info': 'Open/close the fold under the cursor. Native z-commands still work.', 'ex': 'Collapse a long function'})
call s:map('x', '<leader>y', ':<C-u>call my#clip#copy_selection()<CR>', 'Copy to system clipboard',
      \ {'info': 'Explicit copy, even when yank-sync (<Space>tc) is off.', 'ex': 'Copy a snippet into the browser'})
call s:map('n', '<leader>p', ':call my#clip#paste("p")<CR>', 'Paste system clipboard after',
      \ {'info': 'Reads the desktop clipboard (xclip/wl-paste).', 'ex': 'Paste a URL copied in the browser'})
call s:map('n', '<leader>P', ':call my#clip#paste("P")<CR>', 'Paste system clipboard before')
for s:i in range(1, 9)
  call s:map('n', '<leader>' . s:i, ':call my#find#main_window() <Bar> call lightline#bufferline#go(' . s:i . ')<CR>',
        \ 'Go to buffer ' . s:i, s:i == 1
        \ ? {'info': 'Numbers are shown as superscripts in the buffer line (top).', 'ex': '<Space>3 → third buffer', 'wk': 'Go to buffer 1…9'}
        \ : {'wk': 'which_key_ignore'})
endfor
unlet s:i

" ══ f — Find & search ═════════════════════════════════════════════════════════
if s:fzf
  call s:map('n', '<leader>ff', ':call my#find#main_window() <Bar> Files<CR>', 'Files (all)', {'info': 'Every file under the working directory (respects .gitignore).', 'ex': 'Open a file that is not tracked by git yet', 'cond': 'fzf'})
  call s:map('n', '<leader>fg', ':call my#find#main_window() <Bar> GFiles<CR>', 'Git-tracked files', {'info': 'Only files in the git index.', 'cond': 'fzf'})
  call s:map('n', '<leader>fr', ':call my#find#main_window() <Bar> History<CR>', 'Recent files', {'info': 'Most recently opened files (open buffers first).', 'ex': 'Jump back to yesterday''s file', 'cond': 'fzf'})
  call s:map('n', '<leader>fb', ':call my#find#main_window() <Bar> Buffers<CR>', 'Open buffers', {'cond': 'fzf'})
  call s:map('n', '<leader>fd', ':call my#find#main_window() <Bar> DirFiles<CR>', 'Files next to this one', {'info': 'Files in the current file''s directory.', 'ex': 'Open the sibling test file', 'cond': 'fzf'})
  call s:map('n', '<leader>fw', ':call my#find#main_window() <Bar> GrepWord<CR>', 'Grep word under cursor', {'info': 'Whole-word, literal match across the project.', 'ex': 'Find all call sites of a function', 'cond': 'fzf'})
  call s:map('x', '<leader>fw', ':<C-u>call my#find#main_window() <Bar> execute "GrepWord " . my#find#selection()<CR>', 'Grep selection', {'info': 'Literal search for the selected text.', 'cond': 'fzf'})
  call s:map('n', '<leader>fs', ':call my#find#main_window() <Bar> BLines<CR>', 'Search in this file', {'info': 'Fuzzy search the lines of the current buffer.', 'ex': 'Jump to a line you half remember', 'cond': 'fzf'})
  call s:map('n', '<leader>fl', ':call my#find#main_window() <Bar> Lines<CR>', 'Search in open buffers', {'cond': 'fzf'})
  call s:map('n', '<leader>fc', ':Commands<CR>', 'Command palette', {'info': 'Fuzzy-pick any Ex command.', 'ex': 'Run a :Git subcommand without remembering it', 'cond': 'fzf'})
  call s:map('n', '<leader>f:', ':History:<CR>', 'Command history', {'cond': 'fzf'})
  call s:map('n', '<leader>f/', ':History/<CR>', 'Search history', {'cond': 'fzf'})
  call s:map('n', '<leader>fm', ':Marks<CR>', 'Marks', {'cond': 'fzf'})
  call s:map('n', '<leader>fj', ':Jumps<CR>', 'Jump list', {'cond': 'fzf'})
  call s:map('n', '<leader>ft', ':Filetypes<CR>', 'Set filetype', {'info': 'Pick a filetype for the current buffer.', 'cond': 'fzf'})
else
  call s:map('n', '<leader>ff', ':call my#find#fallback_files()<CR>', 'Files (:find)', {'cond': 'fallback'})
  call s:map('n', '<leader>fr', ':browse oldfiles<CR>', 'Recent files', {'cond': 'fallback'})
  call s:map('n', '<leader>fb', ':call my#find#fallback_buffers()<CR>', 'Open buffers', {'cond': 'fallback'})
  call s:map('n', '<leader>fw', ':call my#find#fallback_grep(expand("<cword>"))<CR>', 'Grep word under cursor', {'cond': 'fallback'})
endif

" ══ b — Buffers ═══════════════════════════════════════════════════════════════
call s:map('n', '<leader>bb', s:fzf ? ':call my#find#main_window() <Bar> Buffers<CR>' : ':call my#find#fallback_buffers()<CR>', 'Switch buffer', {'info': 'Fuzzy list of open buffers.', 'ex': 'Hop between 10 open files'})
call s:map('n', '<leader>bn', ':bnext<CR>', 'Next buffer')
call s:map('n', '<leader>bp', ':bprevious<CR>', 'Previous buffer')
call s:map('n', '<leader>ba', ':buffer #<CR>', 'Alternate buffer', {'info': 'Toggle between the two most recent buffers (same as <C-^>).'})
call s:map('n', '<leader>bd', ':BufDelete<CR>', 'Close buffer', {'info': 'Deletes the buffer but keeps your window layout.', 'ex': 'Close a file without collapsing the split'})
call s:map('n', '<leader>bD', ':BufDelete!<CR>', 'Close buffer (discard changes)')
call s:map('n', '<leader>bo', ':BufOnly<CR>', 'Close other buffers', {'info': 'Keeps the current buffer and anything unsaved.'})
call s:map('n', '<leader>bN', ':enew<CR>', 'New empty buffer', {'info': 'Scratch space; :w name to save it.'})
call s:map('n', '<leader>by', ':call my#clip#copy_path(":~:.")<CR>', 'Copy relative path', {'info': 'To the system clipboard.', 'ex': 'Paste the path into a PR comment'})
call s:map('n', '<leader>bY', ':call my#clip#copy_path(":p")<CR>', 'Copy absolute path')
call s:map('n', '<leader>bh', ':call my#dashboard#open()<CR>', 'Dashboard (start screen)', {'info': 'Recent files, projects, sessions and commands; opening anything replaces it.', 'ex': 'Jump back to a project you worked on yesterday', 'cond': 'vim-startify'})
call s:map('n', ']b', ':bnext<CR>', 'Next buffer', {'cat': 'Navigation'})
call s:map('n', '[b', ':bprevious<CR>', 'Previous buffer', {'cat': 'Navigation'})

" ══ w — Windows & tabs ════════════════════════════════════════════════════════
call s:map('n', '<leader>wv', ':vsplit<CR>', 'Split vertically')
call s:map('n', '<leader>ws', ':split<CR>', 'Split horizontally')
call s:map('n', '<leader>wc', '<C-w>c', 'Close window')
call s:map('n', '<leader>wo', '<C-w>o', 'Close other windows')
call s:map('n', '<leader>w=', '<C-w>=', 'Equalize sizes')
call s:map('n', '<leader>wm', ':call my#edit#zoom()<CR>', 'Maximize / restore', {'info': 'Zoom the window; press again to restore the layout.', 'ex': 'Focus on one split temporarily'})
call s:map('n', '<leader>wx', '<C-w>x', 'Swap with next window')
call s:map('n', '<leader>wr', '<C-w>r', 'Rotate windows')
call s:map('n', '<leader>ww', '<C-w>p', 'Previous window')
call s:map('n', '<leader>wH', '<C-w>H', 'Move window far left')
call s:map('n', '<leader>wJ', '<C-w>J', 'Move window to bottom')
call s:map('n', '<leader>wK', '<C-w>K', 'Move window to top')
call s:map('n', '<leader>wL', '<C-w>L', 'Move window far right')
call s:map('n', '<leader>wt', ':tabnew<CR>', 'New tab', {'info': 'Opens a new tab page; gt / gT switch between tabs.'})
call s:map('n', '<leader>wT', ':tabclose<CR>', 'Close tab', {'info': 'Closes the current tab page.'})
call s:map('n', '<C-h>', '<C-w>h', 'Window left', {'cat': 'Navigation', 'info': 'Move to the window on the left.'})
call s:map('n', '<C-j>', '<C-w>j', 'Window down', {'cat': 'Navigation'})
call s:map('n', '<C-k>', '<C-w>k', 'Window up', {'cat': 'Navigation'})
call s:map('n', '<C-l>', '<C-w>l', 'Window right', {'cat': 'Navigation'})
call s:map('n', '<C-Up>', ':resize +3<CR>', 'Taller window', {'cat': 'Navigation', 'info': 'Needs a terminal that sends Ctrl+arrows (GNOME Terminal does).'})
call s:map('n', '<C-Down>', ':resize -3<CR>', 'Shorter window', {'cat': 'Navigation'})
call s:map('n', '<C-Left>', ':vertical resize -4<CR>', 'Narrower window', {'cat': 'Navigation'})
call s:map('n', '<C-Right>', ':vertical resize +4<CR>', 'Wider window', {'cat': 'Navigation'})

" ══ g — Git ═══════════════════════════════════════════════════════════════════
call s:map('n', '<leader>gg', ':Git<CR>', 'Status (fugitive)', {'info': 'Stage with s, unstage u, diff =, commit cc, help g?.', 'ex': 'Review and stage before committing'})
call s:map('n', '<leader>gc', ':Git commit<CR>', 'Commit')
call s:map('n', '<leader>gC', ':Git commit --amend<CR>', 'Amend last commit')
call s:map('n', '<leader>gp', ':Git push<CR>', 'Push')
call s:map('n', '<leader>gP', ':Git pull --rebase<CR>', 'Pull (rebase)')
call s:map('n', '<leader>gd', ':Gvdiffsplit<CR>', 'Diff this file', {'info': 'Side-by-side against the index; :diffget/:diffput to move hunks.', 'ex': 'See exactly what changed in this file'})
call s:map('n', '<leader>gD', ':Git diff<CR>', 'Diff whole repo')
call s:map('n', '<leader>gb', ':Git blame<CR>', 'Blame (window)', {'info': 'Full-file blame; Enter on a line opens that commit.'})
call s:map('n', '<leader>gB', ':GitBlameLine<CR>', 'Blame this line', {'info': 'Pop-up: commit · author · age · summary.', 'ex': 'Who wrote this and why?'})
call s:map('n', '<leader>gl', s:fzf ? ':call my#find#main_window() <Bar> Commits<CR>' : ':Git log --oneline<CR>', 'Log (repo)', {'info': 'Fuzzy commit browser with diff preview.'})
call s:map('n', '<leader>gL', s:fzf ? ':call my#find#main_window() <Bar> BCommits<CR>' : ':Git log --oneline -- %<CR>', 'Log (this file)')
call s:map('n', '<leader>gm', s:fzf ? ':call my#find#main_window() <Bar> GFiles?<CR>' : ':Git<CR>', 'Modified files', {'info': 'Fuzzy list of changed/untracked files.', 'ex': 'Jump to any file you touched'})
call s:map('n', '<leader>gs', '<Plug>(GitGutterStageHunk)', 'Stage hunk', {'remap': 1, 'ex': 'Commit only part of a file'})
call s:map('n', '<leader>gu', '<Plug>(GitGutterUndoHunk)', 'Undo hunk', {'remap': 1, 'info': 'Revert the hunk under the cursor to the index version (undoable with u).'})
call s:map('n', '<leader>gh', '<Plug>(GitGutterPreviewHunk)', 'Preview hunk', {'remap': 1})
call s:map('n', '<leader>gS', ':Gwrite<CR>', 'Stage file')
call s:map('n', '<leader>gR', ':Gread<CR>', 'Reset buffer to index', {'info': 'Replaces buffer text with the staged version (undoable; not written until you save).'})
call s:map('n', '<leader>gq', ':GitGutterQuickFix <Bar> copen<CR>', 'Hunks → quickfix', {'info': 'All changed hunks in the repo as a list.'})
call s:map('n', '<leader>gz', ':GitGutterFold<CR>', 'Fold unchanged lines', {'info': 'Show only what changed; run again to unfold.'})
call s:map('n', ']h', '<Plug>(GitGutterNextHunk)', 'Next git hunk', {'remap': 1, 'cat': 'Navigation'})
call s:map('n', '[h', '<Plug>(GitGutterPrevHunk)', 'Previous git hunk', {'remap': 1, 'cat': 'Navigation'})
call s:map('ox', 'ih', '<Plug>(GitGutterTextObjectInnerPending)', 'Inside hunk (text object)', {'remap': 1, 'cat': 'Text objects', 'ex': 'dih deletes the change; vih selects it'})
call s:map('ox', 'ah', '<Plug>(GitGutterTextObjectOuterPending)', 'Around hunk (text object)', {'remap': 1, 'cat': 'Text objects'})

" ══ c — Code ══════════════════════════════════════════════════════════════════
call s:map('n', '<leader>cc', '<Plug>CommentaryLine', 'Toggle comment (line)', {'remap': 1, 'info': 'Works with a count: 5<Space>cc. Operator form: gc{motion}.', 'ex': 'Comment out a debug print'})
call s:map('x', '<leader>cc', '<Plug>Commentary', 'Toggle comment (selection)', {'remap': 1})
call s:map('n', '<leader>ca', ':LspCodeAction<CR>', 'Code action', {'info': 'Quick fixes / refactors offered by the language server.', 'ex': 'Add a missing import', 'cond': 'LSP server'})
call s:map('x', '<leader>ca', ':LspCodeAction<CR>', 'Code action (range)', {'cond': 'LSP server'})
call s:map('n', '<leader>cr', ':LspRename<CR>', 'Rename symbol', {'info': 'Project-wide, semantic rename.', 'ex': 'Rename a function everywhere', 'cond': 'LSP server'})
call s:map('n', '<leader>cf', ':call my#complete#format(0)<CR>', 'Format buffer', {'info': 'prettier (web files) → language server → autopep8 (python) → Vim = indent.', 'ex': 'Tidy a file before committing'})
call s:map('x', '<leader>cf', ':<C-u>call my#complete#format(1)<CR>', 'Format selection')
call s:map('n', '<leader>co', ':LspCodeActionSync source.organizeImports<CR>', 'Organize imports', {'cond': 'LSP server (pyright / tsserver / gopls)'})
call s:map('n', '<leader>cs', ':VsnipOpen!<CR>', 'Edit snippets (this filetype)', {'info': 'Your own snippets: ~/.vim/snippets/<filetype>.json (VS Code format). Expand with <C-j> in insert mode.', 'ex': 'Add a "logger" snippet for Python'})

" ══ l — LSP & diagnostics ═════════════════════════════════════════════════════
call s:map('n', '<leader>ld', ':LspDefinition<CR>', 'Go to definition', {'info': 'Also gd and <C-]> in LSP buffers.', 'cond': 'LSP server'})
call s:map('n', '<leader>lD', ':LspDeclaration<CR>', 'Go to declaration', {'cond': 'LSP server'})
call s:map('n', '<leader>lr', ':LspReferences<CR>', 'Find references', {'info': 'Into the location list.', 'ex': 'Who calls this method?', 'cond': 'LSP server'})
call s:map('n', '<leader>li', ':LspImplementation<CR>', 'Go to implementation', {'cond': 'LSP server'})
call s:map('n', '<leader>ly', ':LspTypeDefinition<CR>', 'Go to type definition', {'cond': 'LSP server'})
call s:map('n', '<leader>lh', ':LspHover<CR>', 'Hover documentation', {'info': 'Also K. <C-f>/<C-b> scroll the pop-up.', 'cond': 'LSP server'})
call s:map('n', '<leader>ls', ':LspDocumentSymbolSearch<CR>', 'Symbols in file', {'info': 'Outline: functions, classes, …', 'ex': 'Jump to a method by name', 'cond': 'LSP server'})
call s:map('n', '<leader>lS', ':LspWorkspaceSymbolSearch<CR>', 'Symbols in workspace', {'cond': 'LSP server'})
call s:map('n', '<leader>lo', ':Vista!!<CR>', 'Symbol outline (sidebar)', {'info': 'Classes, functions, … of this file on the right, from the language server. Cursor stays in the code; <C-l> enters the outline, <CR> jumps, q closes. Loads on first use.', 'ex': 'Get an overview of a 2000-line module', 'cond': 'LSP server'})
call s:map('n', '<leader>le', ':LspDocumentDiagnostics<CR>', 'Diagnostics list', {'info': 'All errors/warnings of this file in the location list.', 'cond': 'LSP server'})
call s:map('n', '<leader>ln', ':LspNextDiagnostic<CR>', 'Next diagnostic', {'info': 'Also ]d.', 'cond': 'LSP server'})
call s:map('n', '<leader>lp', ':LspPreviousDiagnostic<CR>', 'Previous diagnostic', {'info': 'Also [d.', 'cond': 'LSP server'})
call s:map('n', '<leader>lc', ':LspCallHierarchyIncoming<CR>', 'Incoming calls', {'cond': 'LSP server'})
call s:map('n', '<leader>lx', ':LspStatus<CR>', 'Server status', {'info': 'Which servers are running for this buffer.', 'ex': 'Troubleshoot "LSP does not start"'})
call s:map('n', '<leader>lI', ':LspInstallServer<CR>', 'Install server for filetype', {'info': 'User-local install via vim-lsp-settings.'})
call s:map('n', '<leader>lM', ':LspManageServers<CR>', 'Manage servers', {'info': 'Install / update / uninstall servers (vim-lsp-settings UI).'})

" ══ r — Run & test ════════════════════════════════════════════════════════════
call s:map('n', '<leader>rr', ':call my#run#file()<CR>', 'Run this file', {'info': 'python3 / bash / node / go run / gcc in a bottom terminal; :source for Vim files.', 'ex': 'Run a script and keep its output visible'})
call s:map('n', '<leader>rt', ':call my#run#pytest_scope()<CR>', 'pytest: test under cursor', {'info': 'Finds the enclosing def test_* (and its class) and runs only that test.', 'ex': 'Iterate on one failing test'})
call s:map('n', '<leader>rf', ':call my#run#pytest_file()<CR>', 'pytest: this file', {'info': 'pytest -vvv on the current file (also F8 in Python buffers).'})
call s:map('n', '<leader>rT', ':call my#run#pytest_all()<CR>', 'pytest: whole project', {'info': 'python -m pytest -q with the project virtualenv (.venv / venv / $VIRTUAL_ENV) when there is one.', 'ex': 'Full test run before pushing'})
call s:map('n', '<leader>rv', ':call my#run#pytest_cov(0)<CR>', 'Coverage run (project)', {'info': 'pytest --cov=<dir name> tests  (also F7 in Python buffers).'})
call s:map('n', '<leader>rV', ':call my#run#pytest_cov(1)<CR>', 'Coverage run (this file)', {'info': 'pytest --cov on the current file (also F10 in Python buffers).'})
call s:map('n', '<leader>rc', ':HighlightCoverage<CR>', 'Show coverage highlights', {'info': 'Marks uncovered lines from .coverage.', 'cond': 'python buffer'})
call s:map('n', '<leader>rC', ':HighlightCoverageOff<CR>', 'Hide coverage highlights', {'info': 'Removes the coverage marks.', 'cond': 'python buffer'})
call s:map('n', '<leader>rm', ':call my#run#make()<CR>', 'make → quickfix', {'info': 'Errors become a jumpable list.', 'ex': 'Build, then ]q through compiler errors'})
call s:map('n', '<leader>rM', ':call my#run#make_flash()<CR>', 'make flash', {'info': 'Asks first, then runs in a terminal split. Never runs automatically.'})
call s:map('n', '<leader>rk', ':call my#run#make_target()<CR>', 'make: pick a target', {'info': 'Fuzzy list of the Makefile''s targets; flash/install/deploy-like targets ask before running.', 'ex': 'make test / make lint without typing'})
call s:map('n', '<leader>rl', ':call my#run#last()<CR>', 'Re-run last command', {'info': 'Repeats the last run/test/build command (saves the file first).', 'ex': 'Edit, Space r l, edit, Space r l …'})
call s:map('n', '<leader>rb', ':call my#run#build_ext()<CR>', 'Cython build_ext', {'info': 'python3 setup.py build_ext --inplace --define=CYTHON_TRACE.'})

" ══ x — Lists (quickfix / location) ═══════════════════════════════════════════
call s:map('n', '<leader>xq', ':call my#edit#toggle_list(0)<CR>', 'Toggle quickfix list', {'ex': 'Review grep results or build errors'})
call s:map('n', '<leader>xl', ':call my#edit#toggle_list(1)<CR>', 'Toggle location list', {'info': 'LSP references/diagnostics land here.'})
call s:map('n', ']q', ':cnext<CR>zz', 'Next quickfix item', {'cat': 'Navigation'})
call s:map('n', '[q', ':cprevious<CR>zz', 'Previous quickfix item', {'cat': 'Navigation'})
call s:map('n', ']l', ':lnext<CR>zz', 'Next location item', {'cat': 'Navigation'})
call s:map('n', '[l', ':lprevious<CR>zz', 'Previous location item', {'cat': 'Navigation'})

" ══ s — Save & substitute ═════════════════════════════════════════════════════
call s:map('n', '<leader>ss', ':update<CR>', 'Save', {'info': 'Writes only if changed.'})
call s:map('n', '<leader>sa', ':wall<CR>', 'Save all')
call s:map('n', '<leader>sn', ':noautocmd write<CR>', 'Save without formatting', {'info': 'Skips format-on-save and whitespace trimming for this write.', 'ex': 'Commit a file exactly as-is'})
call s:map('n', '<leader>sr', 'my#edit#substitute_prompt(0)', 'Replace word in file', {'expr': 1, 'silent': 0, 'info': 'Pre-fills `:%s/\<word\>/word/gc`: edit the replacement, press Enter, confirm each match with `y`/`n`.', 'ex': 'Rename a local variable'})
call s:map('x', '<leader>sr', '<Esc>:<C-r>=my#edit#substitute_prompt(1)[1:]<CR>', 'Replace selection in file', {'silent': 0})
call s:map('n', '<leader>sc', ':nohlsearch<CR>', 'Clear search highlight', {'info': 'Hides the highlight of the last search until the next search.'})
call s:map('n', '<leader>st', ':TrimWhitespace<CR>', 'Trim trailing whitespace')
call s:map('nix', '<C-s>', '<Cmd>update<CR>', 'Save', {'cat': 'Editing', 'info': 'Works in Normal, Insert and Visual mode.'})

" ══ t — Toggles & theme ═══════════════════════════════════════════════════════
call s:map('n', '<leader>tt', ':call my#term#toggle()<CR>', 'Terminal panel', {'info': 'Bottom shell that keeps running while hidden. <Esc><Esc> → Normal mode.', 'ex': 'Run git/npm without leaving Vim'})
call s:map('n', '<leader>tb', ':call my#ui#toggle_theme()<CR>', 'Dark / light theme', {'info': 'Your dark theme (Space Vim Dark by default) ↔ Catppuccin Latte; status line follows.', 'ex': 'Switch to light in a sunny room'})
call s:map('n', '<leader>tB', ':call my#ui#cycle_theme()<CR>', 'Cycle theme', {'info': 'Space Vim Dark → Catppuccin Mocha → Catppuccin Latte. Status line, explorer, pop-ups follow.', 'ex': 'Compare themes in daylight'})
call s:map('n', '<leader>tp', ':ThemePreview<CR>', 'Preview themes', {'info': 'Pop-up list of every installed colour scheme; colours change as you move. Enter keeps the choice for this session, Esc restores. Never changes your default.', 'ex': 'Try Catppuccin Mocha or a darker background without editing any file'})
call s:map('n', '<leader>tR', ':Theme<CR>', 'Restore default theme', {'info': 'Back to the theme Vim started with (g:my_theme in ~/.vim/local.vim, else Space Vim Dark).', 'ex': 'Undo any amount of theme cycling'})
call s:map('n', '<leader>tF', ':call my#term#float()<CR>', 'Floating terminal', {'info': 'Centred pop-up shell that survives hiding (also F12). F12 inside hides it.', 'ex': 'Quick git/npm command without changing the layout'})
call s:map('n', '<F12>', ':call my#term#float()<CR>', 'Floating terminal', {'cat': 'Terminal', 'info': 'Same as Space t F.', 'ex': 'F12, run a command, F12 to hide'})
call s:map('t', '<F12>', '<Cmd>call my#term#float()<CR>', 'Hide floating terminal', {'cat': 'Terminal', 'info': 'The shell keeps running; F12 brings it back.', 'ex': 'Hide a long build while you keep editing'})
call s:map('n', '<leader>tz', ':Goyo<CR>', 'Zen mode', {'info': 'Centered, distraction-free writing (Goyo).', 'ex': 'Write docs or a long commit message'})
call s:map('n', '<leader>tn', ':set number! relativenumber!<CR>', 'Line numbers')
call s:map('n', '<leader>tr', ':let w:my_no_rnu = &relativenumber <Bar> setlocal relativenumber!<CR>', 'Relative numbers')
call s:map('n', '<leader>tw', ':call my#core#toggle("wrap")<CR>', 'Soft wrap')
call s:map('n', '<leader>ts', ':call my#core#toggle("spell")<CR>', 'Spell check')
call s:map('n', '<leader>tl', ':call my#core#toggle("list")<CR>', 'Invisible characters')
call s:map('n', '<leader>ti', ':call my#ui#toggle_indent_guides()<CR>', 'Indent guides')
call s:map('n', '<leader>tg', ':GitGutterToggle<CR>', 'Git signs')
call s:map('n', '<leader>tf', ':call my#core#toggle_flag("my_format_on_save", "Format on save")<CR>', 'Format on save', {'info': 'prettier (projects with a prettier config), gofmt, whitespace trim for C/Python.'})
call s:map('n', '<leader>tc', ':call my#core#toggle_flag("my_clipboard_sync", "Yank → system clipboard")<CR>', 'Clipboard sync', {'info': 'When on, every yank (y) is also copied to the desktop clipboard.'})
call s:map('n', '<leader>td', ':call my#complete#toggle_virtual_text()<CR>', 'Inline diagnostics', {'info': 'Show/hide the messages at the end of lines (signs stay).', 'cond': 'LSP server'})
call s:map('n', '<leader>th', ':set hlsearch!<CR>', 'Search highlighting')
call s:map('n', '<leader>tm', ':let &mouse = empty(&mouse) ? "a" : "" <Bar> echo "Mouse: " . (empty(&mouse) ? "off" : "on")<CR>', 'Mouse', {'info': 'Off → the terminal handles mouse selection/copy directly.'})
call s:map('n', '<leader>tC', ':let &l:colorcolumn = empty(&l:colorcolumn) ? "+1" : ""<CR>', 'Column guide', {'info': 'Line at textwidth+1 (column 80 for most of your filetypes).'})

" ══ q — Quit & sessions ═══════════════════════════════════════════════════════
call s:map('n', '<leader>qq', ':confirm qall<CR>', 'Quit all', {'info': 'Asks about unsaved buffers.'})
call s:map('n', '<leader>qQ', ':qall!<CR>', 'Quit all (discard changes)')
call s:map('n', '<leader>qw', ':wqall<CR>', 'Save all and quit')
call s:map('n', '<leader>qs', ':SessionSave<CR>', 'Save session', {'info': 'Per-directory session in ~/.vim/state/sessions.', 'ex': 'Park a multi-split layout for tomorrow'})
call s:map('n', '<leader>ql', ':SessionLoad<CR>', 'Load session')
call s:map('n', '<leader>qd', ':SessionDelete<CR>', 'Delete session')

" ══ h — Help & health ═════════════════════════════════════════════════════════
call s:map('n', '<leader>hc', ':Guide<CR>', 'Help guide & cheat sheet', {'info': 'Topic menu: start here, all shortcuts (press 2), features, workflows, themes, languages, plugins, AI, Vim essentials, health. - goes back, q closes. :Cheatsheet still opens the key list directly.'})
call s:map('n', '<leader>hk', s:fzf ? ':Maps<CR>' : ':map<CR>', 'Search all mappings', {'info': 'Every active mapping (incl. plugins), fuzzy-searchable.'})
call s:map('n', '<leader>ht', s:fzf ? ':Helptags<CR>' : ':help ', 'Search help tags', {'silent': s:fzf})
call s:map('n', '<leader>hh', ':VimHealth<CR>', 'Health check', {'info': 'Versions, tools, clipboard, colours, LSP servers, plugins.', 'ex': 'First stop when something misbehaves'})
call s:map('n', '<leader>hm', ':messages<CR>', 'Messages')
call s:map('n', '<leader>hr', ':call my#health#readme()<CR>', 'Open the full guide')
call s:map('n', '<leader>hp', ':PlugStatus<CR>', 'Plugin status')
call s:map('n', '<leader>hu', ':ConfigUpdate<CR>', 'Update plugins (with snapshot)', {'info': 'Saves a restore snapshot first, then :PlugUpdate.'})

" ══ Editing (non-leader) ══════════════════════════════════════════════════════
call s:map('n', 'Y', 'y$', 'Yank to end of line', {'cat': 'Editing', 'info': 'Consistent with D and C.'})
call s:map('n', 'n', 'nzzzv', 'Next match (centered)', {'cat': 'Editing'})
call s:map('n', 'N', 'Nzzzv', 'Previous match (centered)', {'cat': 'Editing'})
call s:map('n', 'J', 'mzJ`z', 'Join lines (cursor stays)', {'cat': 'Editing'})
call s:map('n', 'Q', '@q', 'Replay macro q', {'cat': 'Editing', 'info': 'Record with qq … q, replay with Q (Ex mode is still :visual / gQ).', 'ex': 'Apply the same edit to 20 lines: 20Q'})
nnoremap <silent> <Plug>(my-blank-below) :<C-u>call my#edit#blank_lines(1)<CR>
nnoremap <silent> <Plug>(my-blank-above) :<C-u>call my#edit#blank_lines(0)<CR>
call s:map('n', ']<Space>', '<Plug>(my-blank-below)', 'Blank line below', {'remap': 1, 'cat': 'Editing', 'info': 'Adds blank line(s) below without entering Insert mode. Count-aware, repeatable.'})
call s:map('n', '[<Space>', '<Plug>(my-blank-above)', 'Blank line above', {'remap': 1, 'cat': 'Editing'})
call s:map('x', '<', '<gv', 'Outdent (keep selection)', {'cat': 'Editing'})
call s:map('x', '>', '>gv', 'Indent (keep selection)', {'cat': 'Editing'})
call s:map('x', 'J', ":move '>+1<CR>gv=gv", 'Move selection down', {'cat': 'Editing', 'ex': 'Reorder lines without cut/paste'})
call s:map('x', 'K', ":move '<-2<CR>gv=gv", 'Move selection up', {'cat': 'Editing'})
call s:map('x', 'p', 'P', 'Paste without losing register', {'cat': 'Editing', 'info': 'The yanked text stays in the register, so it can be pasted over many selections.'})
call s:map('x', '*', ':<C-u>call my#edit#visual_search("/")<CR>', 'Search selection forward', {'cat': 'Editing'})
call s:map('x', '#', ':<C-u>call my#edit#visual_search("?")<CR>', 'Search selection backward', {'cat': 'Editing'})
call s:map('o', 'ie', ':<C-u>normal! ggVG<CR>', 'Entire buffer (text object)', {'cat': 'Text objects', 'ex': 'yie copies the whole file; =ie re-indents it'})
call s:map('x', 'ie', ':<C-u>normal! ggVG<CR>', 'Select entire buffer', {'cat': 'Text objects'})
call s:map('n', '<F1>', '<Esc>', 'Disabled (no accidental help)', {'cat': 'Editing', 'info': 'F1 sits next to Esc; it acts as Esc instead of opening help.'})
call s:map('i', '<F1>', '<Esc>', 'Disabled (no accidental help)', {'cat': 'Editing'})
if s:fern
  call s:map('n', '<C-n>', ':call my#fern#toggle()<CR>', 'Explorer (toggle)', {'cat': 'Navigation', 'info': 'The familiar NERDTree-style toggle key; same as <Space>e.'})
endif
call s:map('n', '<C-p>', s:fzf ? ':call my#find#main_window() <Bar> ProjectFiles<CR>' : ':call my#find#fallback_files()<CR>', 'Find project files', {'cat': 'Navigation', 'info': 'IDE-style alias of <Space><Space>.'})

" ══ Insert mode ═══════════════════════════════════════════════════════════════
call s:map('i', '<Tab>', 'pumvisible() ? "\<C-n>" : "\<Tab>"', 'Next completion / Tab', {'expr': 1, 'cat': 'Insert & completion'})
call s:map('i', '<S-Tab>', 'pumvisible() ? "\<C-p>" : "\<C-h>"', 'Previous completion', {'expr': 1, 'cat': 'Insert & completion'})
call s:map('i', '<C-Space>', '<Plug>(asyncomplete_force_refresh)', 'Trigger completion', {'remap': 1, 'cat': 'Insert & completion', 'info': 'Some terminals send <C-@> for Ctrl+Space; both are mapped.'})
call s:map('i', '<C-@>', '<Plug>(asyncomplete_force_refresh)', 'Trigger completion (terminal code)', {'remap': 1, 'cat': 'Insert & completion'})
call s:map('i', '<C-u>', '<C-g>u<C-u>', 'Delete to line start (undoable)', {'cat': 'Insert & completion'})
call s:map('i', '<C-w>', '<C-g>u<C-w>', 'Delete word (undoable)', {'cat': 'Insert & completion'})
call s:map('is', '<C-j>', "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'", 'Snippet: expand / next field', {'expr': 1, 'remap': 1, 'cat': 'Insert & completion', 'info': 'Expands the snippet name before the cursor, then jumps through its fields. Plain <C-j> elsewhere.', 'ex': 'main<C-j> in a .py file → main() + __main__ guard'})
call s:map('is', '<C-k>', "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'", 'Snippet: previous field', {'expr': 1, 'remap': 1, 'cat': 'Insert & completion', 'info': 'Only inside an active snippet; otherwise <C-k> still enters digraphs.', 'ex': 'Go back to fix the first argument'})
call s:doc('i', '<CR>', 'Accept completion / smart newline', {'cat': 'Insert & completion', 'scope': 'set at VimEnter', 'check': 1,
      \ 'info': 'Selected item → accept; menu open but nothing selected → close + newline; between {} → indented block.'})

" ══ Command line & terminal ═══════════════════════════════════════════════════
call s:map('c', '%%', 'getcmdtype() ==# ":" ? expand("%:h") . "/" : "%%"', 'Insert current file''s directory', {'expr': 1, 'silent': 0, 'cat': 'Command line', 'ex': ':e %%new_file.py'})
call s:doc('c', ':W  /  :Wa', 'Typo guard → :w / :wa', {'cat': 'Command line', 'scope': 'command-line abbreviation'})
call s:doc('t', '<Esc><Esc>', 'Terminal → Normal mode', {'cat': 'Terminal', 'scope': 'terminal panel (<Space>tt) and floating terminal (F12)', 'info': 'Single <Esc> still reaches the shell / fzf.'})
call s:doc('t', '<C-w>N  or  <C-\><C-n>', 'Terminal → Normal mode (any terminal)', {'cat': 'Terminal', 'scope': 'Vim built-in'})
call s:doc('t', '<C-w>h/j/k/l', 'Leave terminal to another window', {'cat': 'Terminal', 'scope': 'Vim built-in'})

" ══ Buffer-local keys defined elsewhere (documented here, verified by tests) ══
" LSP buffers (lsp.vim → s:on_lsp_buffer_enabled)
for [s:l, s:d, s:x] in [['gd', 'Go to definition', 'Also <C-]> (tagfunc)'], ['gD', 'Go to declaration', ''],
      \ ['gr', 'Find references', ''], ['gI', 'Go to implementation', 'gi (insert at last insert) stays native'],
      \ ['gy', 'Go to type definition', ''], ['K', 'Hover documentation', ''],
      \ ['[d', 'Previous diagnostic', ''], [']d', 'Next diagnostic', ''],
      \ ['<C-f> / <C-b>', 'Scroll hover pop-up', 'Normal paging when no pop-up is open']]
  call s:doc('n', s:l, s:d, {'cat': 'LSP buffers', 'scope': 'only when a server is attached', 'info': s:x})
endfor
" Python buffers: F-keys for the test workflow
for [s:l, s:d] in [['<F7>', 'pytest --cov (project)'], ['<F8>', 'pytest this file'], ['<F9>', 'Run with python3'], ['<F10>', 'pytest --cov (this file)']]
  call s:doc('n', s:l, s:d, {'cat': 'Python buffers', 'scope': 'python filetype'})
endfor
augroup my_python_keys
  autocmd!
  autocmd FileType python nnoremap <buffer><silent> <F7>  :call my#run#pytest_cov(0)<CR>
  autocmd FileType python nnoremap <buffer><silent> <F8>  :call my#run#pytest_file()<CR>
  autocmd FileType python nnoremap <buffer><silent> <F9>  :call my#run#file()<CR>
  autocmd FileType python nnoremap <buffer><silent> <F10> :call my#run#pytest_cov(1)<CR>
augroup END
" Explorer (fern) buffer keys — see autoload/my/fern.vim
for [s:l, s:d] in [['<CR> / l / o', 'Open file / expand folder'], ['h', 'Collapse folder'],
      \ ['s / v / t', 'Open in split / vsplit / tab'], ['- / <BS>', 'Go up to parent directory'],
      \ ['=', 'Make folder the root'], ['a', 'New file (end with / for a folder)'], ['r', 'Rename'],
      \ ['c / m', 'Copy / move'], ['d', 'Move to trash'], ['D', 'Delete permanently (asks)'],
      \ ['y', 'Copy path (Vim register)'], ['x', 'Mark (for batch operations)'], ['!', 'Show/hide dotfiles'],
      \ ['I', 'Toggle ignore filter (build/, dist/, …)'], ['R', 'Reload'], ['gc', 'cd (tab) to folder'],
      \ ['X', 'Open with system app'], ['?', 'All fern actions'], ['q', 'Close the drawer']]
  call s:doc('n', s:l, s:d, {'cat': 'Explorer (fern)', 'scope': 'explorer window'})
endfor
unlet! s:l s:d s:x

" Dashboard (Startify) — keys inside the start screen
for [s:l, s:d, s:x] in [['0-9 / a d m …', 'Open the numbered entry', 'Press 0 to reopen the last file of this project'],
      \ ['<CR>', 'Open entry under cursor', 'j j <CR> opens the third entry'],
      \ ['f / g / r', 'Find file / grep / recent files (fzf)', 'g, type TODO → every TODO in the project'],
      \ ['l', 'Restore this directory''s session', 'Get yesterday''s splits back'],
      \ ['c', 'Edit configuration', 'Opens ~/.vim/vimrc, explorer shows ~/.vim'],
      \ ['h', 'Help guide & shortcuts', 'Look up a key you forgot'],
      \ ['b / s / v / t', 'Mark entry: open in buffer / split / vsplit / tab', 'v on two files, then <CR> → side by side'],
      \ ['e', 'Empty buffer', 'Scratch notes'], ['q', 'Quit', 'Leave Vim from the start screen']]
  call s:doc('n', s:l, s:d, {'cat': 'Dashboard', 'scope': 'start screen (vim with no files, or Space b h)', 'ex': s:x,
        \ 'info': 'Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays.'})
endfor
" Symbol outline (Vista)
for [s:l, s:d, s:x] in [['<CR>', 'Jump to the symbol', 'Jump to class Greeter'],
      \ ['p', 'Preview the symbol', 'Peek at a function without leaving the outline'],
      \ ['s', 'Sort alphabetically / by position', 'Find a method by name in a long class'],
      \ ['/', 'Filter (fzf)', '/ hel → hello()'], ['q', 'Close the outline', 'Same as Space l o']]
  call s:doc('n', s:l, s:d, {'cat': 'Symbol outline (Vista)', 'scope': 'outline window (Space l o)', 'ex': s:x,
        \ 'info': 'Vista key inside the outline; symbols come from the language server and refresh as you type.'})
endfor
unlet! s:l s:d

" ══ Plugin defaults you get for free (documented, not remapped) ═══════════════
for [s:m, s:l, s:d, s:x, s:p] in [
      \ ['n', 'ys{motion}{char}', 'Add surrounding', 'ysiw" → "word"', 'vim-surround'],
      \ ['n', 'yss{char}', 'Surround whole line', 'yss) → (line)', 'vim-surround'],
      \ ['n', 'cs{old}{new}', 'Change surrounding', 'cs"'' → ''word''', 'vim-surround'],
      \ ['n', 'ds{char}', 'Delete surrounding', 'ds( removes parentheses', 'vim-surround'],
      \ ['x', 'S{char}', 'Surround selection', 'viwS] → [word]', 'vim-surround'],
      \ ['nx', 'gc{motion}', 'Comment operator', 'gcap comments a paragraph', 'vim-commentary'],
      \ ['n', 'gcc', 'Comment line', '3gcc comments 3 lines', 'vim-commentary'],
      \ ['o', 'gc', 'Comment block (text object)', 'dgc deletes a comment block', 'vim-commentary'],
      \ ['o', 'ia / aa', 'Argument (inside / around)', 'cia changes one function argument', 'targets.vim'],
      \ ['o', 'in( / il(', 'Next / last pair', 'cin" edits the next string on the line', 'targets.vim'],
      \ ['o', 'i, / a,', 'Between separators', 'ci, changes a CSV field', 'targets.vim'],
      \ ['i', '( [ { " '' `', 'Auto-close pairs', 'Type ( → (|); <BS> deletes both', 'lexima.vim'],
      \ ['n', '.', 'Repeat (also plugin maps)', 'Repeats ys/cs/ds and gitgutter actions', 'vim-repeat'],
      \ ['n', '%', 'Jump between matching pairs', 'if ↔ endif, <div> ↔ </div>', 'matchit (built-in)']]
  call s:doc(s:m, s:l, s:d, {'cat': 'Plugin defaults', 'scope': s:p, 'ex': s:x})
endfor
for [s:l, s:d] in [['s / u / -', 'Stage / unstage / toggle file or hunk'], ['=', 'Inline diff'],
      \ ['cc / ca', 'Commit / amend'], ['dv', 'Vertical diff of file'], ['X', 'Discard change (asks)'],
      \ ['<CR>', 'Open file'], ['g?', 'All fugitive keys']]
  call s:doc('n', s:l, s:d, {'cat': 'Git status window (fugitive)', 'scope': 'inside <Space>gg'})
endfor
for [s:l, s:d] in [['<CR>', 'Open selection'], ['<C-s> / <C-v> / <C-t>', 'Open in split / vsplit / tab'],
      \ ['<Tab> / <S-Tab>', 'Mark / unmark (multi-select)'], ['<C-q>', 'Send marked items to quickfix'],
      \ ['alt-a / alt-d', 'Select / deselect all'], ['<C-/>', 'Toggle preview'],
      \ ['<C-u> / <C-d>', 'Half page up / down'], ['<Esc>', 'Cancel']]
  call s:doc('t', s:l, s:d, {'cat': 'Inside fzf pop-ups', 'scope': 'fzf window'})
endfor
unlet! s:m s:l s:d s:x s:p
