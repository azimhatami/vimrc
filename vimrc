" =============================================================================
" ===                     VIMRC for a DevOps Engineer                     ===
" =============================================================================
" ===        Tailored for Bash, Python, JS, C++, Docker, and Git        ===
" =============================================================================

" -----------------------------------------------------------------------------
" Section 1: Plugin Manager (vim-plug)
" -----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" --- File Explorer & Utilities ---
Plug 'preservim/nerdtree'         " Tree-style file explorer
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Core fuzzy finder
Plug 'junegunn/fzf.vim'           " Vim integration for fzf
Plug 'tpope/vim-fugitive'         " The best Git wrapper for Vim
Plug 'airblade/vim-gitgutter'     " Shows Git diffs in the sign column

" --- Autocompletion Engine ---
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Modern completion engine

" --- UI & UX ---
Plug 'vim-airline/vim-airline'          " A sleek and functional statusline
Plug 'vim-airline/vim-airline-themes' " Themes for Airline
Plug 'ryanoasis/vim-devicons'         " Adds filetype icons to NERDTree and Airline
Plug 'dracula/vim', { 'as': 'dracula' } " A popular and beautiful colorscheme
Plug 'sheerun/vim-polyglot'           " A solid language pack for syntax highlighting
Plug 'scrooloose/nerdcommenter'       " For easily commenting/uncommenting code

call plug#end()

" -----------------------------------------------------------------------------
" Section 2: General & Basic Settings
" -----------------------------------------------------------------------------
set nocompatible                  " Use Vim features, not Vi compatibility
syntax on                         " Enable syntax highlighting
filetype plugin indent on         " Enable filetype-based plugins and indentation

" --- Appearance ---
set number                        " Show line numbers
set relativenumber                " Show relative line numbers for faster navigation
set cursorline                    " Highlight the line the cursor is on
set termguicolors                 " Enable true colors in compatible terminals
set background=dark               " Set a dark background for the colorscheme
colorscheme dracula               " Activate the Dracula colorscheme

" --- Search Settings ---
set incsearch                     " Show search results as you type
set hlsearch                      " Highlight all search results
set ignorecase                    " Ignore case when searching
set smartcase                     " ...unless the search pattern contains an uppercase letter

" --- Editor Behavior ---
set encoding=utf-8                " Use UTF-8 encoding
set autoindent                    " Enable auto-indentation
set smartindent                   " Enable smart indentation for programming
set tabstop=4                     " A tab is 4 spaces wide
set shiftwidth=4                  " Indentation width is 4 spaces
set expandtab                     " Use spaces instead of tabs (crucial for Python/YAML)
set scrolloff=8                   " Always keep 8 lines visible above/below the cursor
set mouse=a                       " Enable mouse support in all modes
set splitright                    " Open new vertical splits to the right
set splitbelow                    " Open new horizontal splits to the bottom

" --- Backup & Swap Files ---
set nobackup
set nowritebackup
set noswapfile

" -----------------------------------------------------------------------------
" Section 3: Key Mappings & Shortcuts
" -----------------------------------------------------------------------------

" --- Leader Key ---
" This is the main key for our custom shortcuts. Set to the Space key.
let mapleader = " "

" --- General Shortcuts ---
" Save file with <Space> + w
nnoremap <leader>w :w<CR>
" Quit Vim with <Space> + q
nnoremap <leader>q :q<CR>
" Close the current buffer with <Space> + c
nnoremap <leader>c :bp<bar>sp<bar>bn<bar>bd<CR>
" Clear search highlight by pressing Enter
nnoremap <CR> :nohlsearch<CR><CR>

" --- NERDTree Shortcuts ---
" Toggle NERDTree with <Space> + n
nnoremap <leader>n :NERDTreeToggle<CR>
" Find the current file in NERDTree
nnoremap <leader>f :NERDTreeFind<CR>

" --- FZF (Fuzzy Finder) Shortcuts ---
" Search for files with Ctrl + p
nnoremap <C-p> :Files<CR>
" Search through open buffers
nnoremap <leader>b :Buffers<CR>
" Search for text within the project (requires 'ag' or 'rg')
nnoremap <leader>g :Ag<CR>

" --- GitGutter Shortcuts ---
" Stage the current hunk
nmap <leader>hs :GitGutterStageHunk<CR>
" Revert (undo) the current hunk
nmap <leader>hr :GitGutterUndoHunk<CR>

" --- CoC (Completion) Shortcuts ---
" Use Tab for completion and navigating the suggestion list
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Go to Definition with gd
nmap <silent> gd <Plug>(coc-definition)
" Show Documentation with K
nmap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Rename with <Space> + rn
nmap <leader>rn <Plug>(coc-rename)
" List References with <Space> + lr
nmap <leader>lr <Plug>(coc-references)


" -----------------------------------------------------------------------------
" Section 4: Plugin-Specific Configurations
" -----------------------------------------------------------------------------

" --- vim-airline ---
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline_theme='dracula'

" --- NERDCommenter ---
" Add a space after the comment delimiter
let g:NERDSpaceDelims = 1

" --- GitGutter ---
" Enable real-time updates for git changes
set updatetime=100
