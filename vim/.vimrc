" vim:foldmethod=marker:set ft=vim:

" General {{{

" Load vim defaults
if !has('nvim')
  source $VIMRUNTIME/defaults.vim
endif

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowritebackup
set noswapfile

" Turn persistent undo on
" means that you can undo even when you close a buffer/VIM
set undofile

" Use system clipboard
if has('clipboard')
  set clipboard=unnamedplus
endif

" }}}

" User interface {{{

" Set title
set title
set titlestring=%F

" Faster update time
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

" Relative numbers
set number
set relativenumber
set numberwidth=3

" Folds
set foldtext=""
set foldlevel=99

" Better file browser
let g:netrw_banner=0
nmap - <CMD>Explore<CR>

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

" Auto comments are annoying, disable them
autocmd FileType * set formatoptions-=cro

" }}}

" Completion {{{

" Better wildmode
set wildoptions=pum

" Enable omnifunc
set omnifunc=syntaxcomplete#Complete

" Smart tab completion
function! Smart_TabComplete()
  let line = getline('.')                         " current line

  let substr = strpart(line, -1, col('.')+1)      " from the start of the current
                                                  " line to one character right
                                                  " of the cursor
  let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
  if (strlen(substr)==0)                          " nothing to match on empty string
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1      " position of period, if any
  let has_slash = match(substr, '\/') != -1       " position of slash, if any
  if (!has_period && !has_slash)
    return "\<C-X>\<C-P>"                         " existing text matching
  elseif ( has_slash )
    return "\<C-X>\<C-F>"                         " file matching
  else
    return "\<C-X>\<C-O>"                         " plugin matching
  endif
endfunction
inoremap <tab> <c-r>=Smart_TabComplete()<CR>

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

" }}}

" User configuration {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
