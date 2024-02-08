" vim:foldmethod=marker:set ft=vim:

" General {{{

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowritebackup
set noswapfile

" Turn persistent undo on
" means that you can undo even when you close a buffer/VIM
set undodir=$HOME/.vim/undodir
set undofile

" Use system clipboard
if has('clipboard')
  set clipboard=unnamedplus
endif

" }}}

" User interface {{{

" set title
set title
set titlestring=%F

set updatetime=100

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Show matching brackets when text indicator is over them
set showmatch

" Always use vertical diffs
set diffopt+=vertical

" Always show some lines under
set scrolloff=8

" Disable text wrap
set nowrap

" Always show the status line
set laststatus=2

" Show cursor line
set cursorline

" Always show the signcolumn
set signcolumn=yes

" Relative numbers
set number
set relativenumber
set numberwidth=3

" Folds
set foldtext=""
set foldlevel=99

" }}}

" Text, tab and indent related {{{

" Use spaces instead of tabs
set expandtab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

" Text width is 80 characters
set textwidth=80

" Better automatic indentation
set smartindent

" Use Unix as the standard file type
set fileformats=unix,dos,mac

" }}}

" Mappings and commands {{{

" With a map leader it's possible to do extra key combinations
let mapleader = ' '
let maplocalleader = ' '
let g:mapleader = ' '

" Navigation
noremap <silent> <leader>" :<C-U>vsplit<cr>
noremap <silent> <leader>% :<C-U>split<cr>
noremap <silent> <leader>x :<C-U>close<cr>

" Emacs like keybindings for the command line (:) and insert mode are better
noremap! <C-A> <Home>
noremap! <C-E> <End>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Useful system mappings
command! W w !sudo tee % > /dev/null
command! X !chmod +x % > /dev/null

" Mark mappings
nnoremap <silent> dm :<C-U>execute 'delmarks '.nr2char(getchar())<CR>
nnoremap <silent> dm<CR> :<C-U>delm a-zA-Z0-9<CR>

" }}}

" User configuration {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
