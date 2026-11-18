" ==============================================================================
"  options.vim — core editor behaviour (built-in options only, no plugins)
" ==============================================================================

" ── Files, undo, swap ─────────────────────────────────────────────────────────
" Everything lives under ~/.vim/state so project directories stay clean.
" The trailing '//' makes Vim encode the full path into swap/backup names.
let &undodir   = g:my_state_dir . '/undo//'
let &directory = g:my_state_dir . '/swap//'
let &backupdir = g:my_state_dir . '/backup//'
for s:d in [&undodir, &directory, &backupdir, g:my_state_dir . '/sessions']
  if !isdirectory(s:d) | call mkdir(s:d, 'p', 0700) | endif
endfor
unlet! s:d
set undofile undolevels=10000 undoreload=10000   " persistent undo
set swapfile nobackup writebackup                " crash safety without litter
set hidden                                        " switch buffers without saving
set autoread                                      " pick up external changes (see checktime below)
set fileformats=unix,dos,mac
set viminfo='300,<50,s10,h                       " remember 300 files' marks, small registers
set history=1000
set sessionoptions=buffers,curdir,folds,help,tabpages,winsize,terminal

" ── UI ────────────────────────────────────────────────────────────────────────
set number relativenumber          " hybrid numbers (absolute in insert/unfocused — see appearance.vim)
set cursorline cursorlineopt=both  " highlight current line + number (only in focused window)
set signcolumn=yes                 " always reserve the sign column → no text jitter
set laststatus=2 showtabline=2     " status line always, buffer line always
set noshowmode                     " the status line shows the mode
set showcmd                        " partial command in the command line
set cmdheight=1
set shortmess+=cIW                 " no completion chatter, no intro screen, no "written"
set shortmess-=S                   " show [3/12] search count
set belloff=all                    " no bells, ever
set scrolloff=6 sidescrolloff=8 sidescroll=1
set nowrap                         " toggle with <Space>tw
set linebreak breakindent breakindentopt=shift:2,sbr showbreak=↪\
set display=lastline,uhex
set splitbelow splitright          " new splits open below / to the right
if exists('+splitkeep') | set splitkeep=screen | endif
if exists('+smoothscroll') | set smoothscroll | endif
set fillchars=vert:│,fold:\ ,eob:\ ,diff:╱,foldopen:▾,foldclose:▸,foldsep:│
set list                           " required for indent guides (listchars set in appearance.vim)
set mouse=a ttymouse=sgr           " optional mouse; Shift+drag still selects in the terminal
set termwinkey=<C-w>
set lazyredraw                     " don't redraw mid-macro
set ttyfast
set synmaxcol=240                  " stop highlighting absurdly long lines

" Pop-up menu & completion
set pumheight=14
set completeopt=menuone,noinsert,noselect,popup
set completepopup=highlight:Pmenu,border:off
set complete-=i complete-=t        " don't scan included files / tags on <C-n> (slow)

" Command-line completion: fuzzy, in a pop-up menu
set wildmenu wildoptions=pum,fuzzy wildmode=longest:full,full
set wildignorecase
set wildignore+=*.o,*.obj,*.so,*.a,*.pyc,*.class,*.swp,*~
set wildignore+=*/.git/*,*/node_modules/*,*/__pycache__/*,*/dist/*,*/build/*,*/.venv/*,*/.mypy_cache/*

" ── Timing ────────────────────────────────────────────────────────────────────
set updatetime=250                 " CursorHold / gitgutter / LSP highlight responsiveness
set timeout timeoutlen=500         " mapping chords
set ttimeout ttimeoutlen=10        " key-code escapes (snappy <Esc>)

" ── Search ────────────────────────────────────────────────────────────────────
set incsearch hlsearch ignorecase smartcase
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --glob\ '!.git'
  set grepformat=%f:%l:%c:%m
elseif executable('git')
  set grepprg=git\ grep\ -n\ --column\ --untracked
  set grepformat=%f:%l:%c:%m
endif

" ── Editing ───────────────────────────────────────────────────────────────────
set backspace=indent,eol,start
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround
set autoindent smartindent
set textwidth=0                    " per-filetype values live in languages.vim
set formatoptions+=j               " remove comment leader when joining lines
set nojoinspaces
set nrformats-=octal               " 007 + <C-a> = 008, not 010
set virtualedit=block              " rectangular selections past end of line
set switchbuf=useopen,uselast
set spelllang=en_us nospell
if exists('+jumpoptions') | set jumpoptions=stack | endif

" Folding: indent-based, everything open on load. Toggle a fold with  za  or  <Space>z.
set foldmethod=indent foldlevelstart=99 foldnestmax=10
set foldtext=my#ui#foldtext()

" Diff
set diffopt+=vertical,algorithm:histogram,indent-heuristic
if has('patch-9.1.1009') | set diffopt+=linematch:60 | endif

" ── Built-in runtime plugins nobody uses any more ──────────────────────────
" getscript/vimball (old script installers), logiPat, rrhelper (--remote-wait
" helper for GUIs). gzip/tar/zip, netrw (fern fallback) and TOhtml stay on.
let g:loaded_getscriptPlugin = 1
let g:loaded_vimballPlugin   = 1
let g:loaded_logiPat         = 1
let g:loaded_rrhelper        = 1

" ── Built-in packages ─────────────────────────────────────────────────────────
packadd! matchit                   " % jumps between if/else/endif, HTML tags…
packadd! editorconfig              " honour .editorconfig in projects
" Vim 9.1.0016's bundled editorconfig raises E495 on BufNew for unnamed
" buffers (:enew, wiping the last buffer). Drop only that trigger; the real
" BufNewFile/BufReadPost handlers keep applying .editorconfig files.
autocmd SourcePost */editorconfig/plugin/editorconfig.vim silent! autocmd! editorconfig BufNew *
packadd! cfilter                   " :Cfilter /pat/ to narrow quickfix lists

" Shell commands (:!) load ~/.bash_aliases when it exists.
if filereadable(expand('~/.bash_aliases'))
  let $BASH_ENV = expand('~/.bash_aliases')
endif
let g:is_bash = 1                  " sh files are bash (better highlighting)

" ── Terminal integration ──────────────────────────────────────────────────────
if !has('gui_running')
  " Cursor shape: bar in insert, underline in replace, block elsewhere.
  let &t_SI = "\e[6 q"
  let &t_SR = "\e[4 q"
  let &t_EI = "\e[2 q"
  " Colored undercurl for diagnostics (VTE, kitty, WezTerm, foot, alacritty…).
  if $VTE_VERSION !=# '' || $TERM =~# 'kitty\|wezterm\|foot\|alacritty' || $TERM_PROGRAM =~# 'WezTerm\|ghostty'
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"
    let &t_8u = "\e[58:2::%lu:%lu:%lum"
  endif
  " Inside tmux/screen, tell Vim how to send true colours.
  if &term =~# '^\%(screen\|tmux\)'
    let &t_8f = "\e[38;2;%lu;%lu;%lum"
    let &t_8b = "\e[48;2;%lu;%lu;%lum"
  endif
endif

augroup my_options
  autocmd!
  " Reload files changed outside Vim when focus/buffer changes.
  autocmd FocusGained,BufEnter,CursorHold * if mode() !~# '[ci]' && getcmdwintype() ==# '' | silent! checktime | endif
  " Return to the last cursor position when reopening a file.
  autocmd BufReadPost * if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line('$') | execute 'normal! g`"zv' | endif
  " Equalise splits when the terminal is resized.
  autocmd VimResized * wincmd =
  " Don't auto-insert comment leaders on o / O / <CR>.
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
  " Make every quickfix/location list window span the bottom.
  autocmd FileType qf wincmd J | setlocal nowrap norelativenumber nolist
augroup END
