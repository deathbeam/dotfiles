" vim:foldmethod=marker:set ft=vim:

" General {{{

" Load vim defaults
if !has('nvim')
  source $VIMRUNTIME/defaults.vim
endif

" Reset all auto commands
augroup VimRc
  autocmd!
augroup END

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowritebackup
set noswapfile

" Turn persistent undo on
" means that you can undo even when you close a buffer/VIM
set undofile

" Do not store garbage in session
set sessionoptions-=blank
set sessionoptions-=help

" }}}

" User interface {{{

" Faster update time
set updatetime=100

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Show matching brackets when text indicator is over them
set showmatch

" Always use vertical diffs
set diffopt=internal,filler,closeoff,linematch:60,context:10,algorithm:histogram,indent-heuristic

" Always show some lines around
set scrolloff=8
set sidescrolloff=8

" Split like normal humain being
set splitbelow
set splitright

" Disable text wrap
set nowrap

" Hide status line
set laststatus=0
set noruler
set statusline=%{repeat('─',winwidth('.')-1)}
set fillchars=stl:─,stlnc:─

" Use title instead of statusline
set title
set titlestring=%F\ %m[%l/%L-%v]

" Never show tab line
set showtabline=0

" Show cursor line
set cursorline

" Relative numbers
set number
set relativenumber
set numberwidth=3

" Color column
set colorcolumn=+1

" Folds
set foldtext=""
set foldlevel=99
set foldmethod=expr

" Disable mouse
set mouse=

" Less annoying messages
set shortmess+=cCI

" Fuzzy search
set wildoptions+=fuzzy

" Better file browser
let g:netrw_banner=0
nmap - <CMD>Explore<CR>

" Automatically rebalance windows on vim resize
autocmd VimRc VimResized * wincmd =

" Restore cursor position on buf enter
autocmd VimRc BufRead * autocmd FileType <buffer> ++once
      \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif

" Disable numbers in quickfix
autocmd VimRc BufWinEnter quickfix set norelativenumber
autocmd VimRc BufWinEnter quickfix set nonumber

" Sync system clipboard and vim clipboard
autocmd VimRc FocusGained,VimEnter * let @"=getreg('+')
autocmd VimRc TextYankPost * if v:event.operator ==# 'y' | let @+=getreg('"') | endif

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
" set smartindent

" Use Unix as the standard file type
set fileformats=unix,dos,mac

" Better jumplist
if has('nvim')
    set jumpoptions=stack
endif

" Auto comments are annoying, disable them
autocmd VimRc FileType * set formatoptions-=cro

" Very magic
vnoremap / <Esc>/\%V
"nnoremap / /\v
"vnoremap / /\v
"cnoremap s/ smagic/

" }}}

" Mappings and commands {{{

" With a map leader it's possible to do extra key combinations
let mapleader = ' '
let maplocalleader = ' '
let g:mapleader = ' '

" Stupid highlight
nmap <silent> <Esc> <CMD>noh<CR>

" Disable Enter key accepting autocomplete (stupid enter)
inoremap <expr> <CR> pumvisible() ? "\<C-e><CR>" : "\<CR>"

" why shift????
noremap ; :

" Navigation
nmap <silent> <leader>" <CMD>vsplit<CR>
nmap <silent> <leader>% <CMD>split<CR>
nmap <silent> <leader>x <CMD>close<CR>

" Emacs like keybindings for the command line (:) and insert mode are better
noremap! <C-A> <Home>
noremap! <C-E> <End>
"noremap! <C-P> <End><C-U><Up>
"noremap! <C-N> <End><C-U><Down>

" Sudo save
command! W execute 'w !sudo -S tee % > /dev/null'

" Mark mappings
"nnoremap <silent> dm     <CMD>execute 'delmarks '.nr2char(getchar())<CR>
"nnoremap <silent> dm<CR> <CMD>delm a-zA-Z0-9<CR>

" }}}

" User configuration {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
