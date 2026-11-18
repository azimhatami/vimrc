" ==============================================================================
"  plugins.vim — plugin manifest (vim-plug)
" ------------------------------------------------------------------------------
"  Rules for this list:
"    • one plugin per job (no overlapping functionality)
"    • lazy-load anything that is only needed on demand
"    • every plugin's configuration lives in the module named in its comment
"    • exact revisions are recorded in ~/.vim/plug-snapshot.vim (the lockfile);
"      restore them with:  vim -S ~/.vim/plug-snapshot.vim
" ==============================================================================

let s:plug = expand('~/.vim/autoload/plug.vim')
if !filereadable(s:plug)
  " No plugin manager: the config still works on built-ins only.
  " Run  ~/.vim/tools/bootstrap.sh  to install vim-plug and every plugin.
  let g:plugs = {}
  call my#core#warn('vim-plug is missing — running on built-in features only (see ~/.vim/README.md › Installation).')
  finish
endif

call plug#begin('~/.vim/plugged')

" ── Appearance ─────────────────────────────────────────────── appearance.vim ─
Plug 'liuchengxu/space-vim-dark'                       " default colour scheme
Plug 'catppuccin/vim', { 'as': 'catppuccin' }          " alternative schemes: mocha (dark) / latte (light)
Plug 'itchyny/lightline.vim'                           " status line engine
Plug 'mengelbrecht/lightline-bufferline'               " buffer list in the tabline
if g:my_icons
  Plug 'lambdalisue/vim-nerdfont'                      " single icon provider (no devicons)
  Plug 'lambdalisue/vim-glyph-palette'                 " colours the icons by file type
endif
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }             " distraction-free mode
Plug 'mhinz/vim-startify'                              " start screen beside the explorer

" ── Navigation ─────────────────────────────────────────────── navigation.vim ─
" The fzf plugin is pinned to the same tag as the ~/.local/bin/fzf binary.
Plug 'junegunn/fzf', { 'tag': 'v0.74.5' }
Plug 'junegunn/fzf.vim'                                " fuzzy files / grep / buffers / history
Plug 'lambdalisue/vim-fern'                            " async file explorer (drawer)
Plug 'lambdalisue/vim-fern-git-status'                 " git status badges in fern
Plug 'lambdalisue/vim-fern-hijack'                     " `vim some/dir` opens fern, not netrw
if g:my_icons
  Plug 'lambdalisue/vim-fern-renderer-nerdfont'        " icon renderer for fern
endif
Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }         " symbol outline sidebar via LSP

" ── Git ───────────────────────────────────────────────────────────── git.vim ─
Plug 'tpope/vim-fugitive'                              " :Git — status, commit, blame, diff
Plug 'airblade/vim-gitgutter'                          " signs + hunk stage/undo/preview

" ── Code intelligence ─────────────────────────────────────────────── lsp.vim ─
Plug 'prabirshrestha/vim-lsp'                          " LSP client (pure Vimscript, async)
Plug 'mattn/vim-lsp-settings'                          " server registry + user-local installer
Plug 'prabirshrestha/asyncomplete.vim'                 " async completion engine
Plug 'prabirshrestha/asyncomplete-lsp.vim'             "   ↳ LSP source
Plug 'prabirshrestha/asyncomplete-buffer.vim'          "   ↳ buffer-words source
Plug 'prabirshrestha/asyncomplete-file.vim'            "   ↳ file-path source
Plug 'hrsh7th/vim-vsnip'                               " snippet engine (VS Code / LSP snippet format)
Plug 'hrsh7th/vim-vsnip-integ'                         "   ↳ snippets in completion + LSP snippet expansion
Plug 'rafamadriz/friendly-snippets'                    "   ↳ community snippet collection (data only)

" ── Editing ───────────────────────────────────────────────────── editing.vim ─
Plug 'tpope/vim-surround'                              " ys / cs / ds surroundings
Plug 'tpope/vim-commentary'                            " gc comment operator
Plug 'tpope/vim-repeat'                                " `.` repeats plugin maps
Plug 'cohama/lexima.vim'                               " dot-repeatable auto-pairs
Plug 'wellle/targets.vim'                              " better text objects (args, seek)
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }     " visual undo history
Plug 'markonm/traces.vim'                              " live preview of :s/…/…/ and ranges
Plug 'tpope/vim-eunuch'                                " :Rename :Move :Delete :Chmod :Mkdir

" ── Discoverability ──────────────────────────────────────────── whichkey.vim ─
Plug 'liuchengxu/vim-which-key'                        " popup menu of <Space> mappings

" ── Languages ─────────────────────────────────────────────────── languages.vim ─
Plug 'evanleck/vim-svelte', { 'branch': 'main', 'for': 'svelte' }
Plug 'prettier/vim-prettier', {
      \ 'do': 'npm install --omit=dev --ignore-scripts --no-audit --no-fund',
      \ 'for': ['javascript', 'typescript', 'javascriptreact', 'typescriptreact',
      \         'css', 'scss', 'less', 'json', 'graphql', 'markdown', 'vue',
      \         'svelte', 'yaml', 'html'] }
Plug 'mgedmin/coverage-highlight.vim', { 'for': 'python' }
Plug 'alvan/vim-closetag', { 'for': ['html', 'xml', 'svelte', 'vue', 'javascriptreact', 'typescriptreact'] }

call plug#end()
