" Plugs {
  call plug#begin('~/.vim/plugged')

  Plug 'kien/ctrlp.vim'
  Plug 'flazz/vim-colorschemes'
  Plug 'scrooloose/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'jistr/vim-nerdtree-tabs'
  Plug 'itchyny/lightline.vim'
  Plug 'shinchu/lightline-gruvbox.vim'
  Plug 'easymotion/vim-easymotion'
  Plug 'scrooloose/nerdcommenter'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'scrooloose/syntastic'
  Plug 'majutsushi/tagbar'
  Plug 'craigemery/vim-autotag'
  Plug 'mhinz/vim-startify'
  Plug 'Shougo/vimproc.vim', {'do' : 'make'}
  Plug 'Shougo/vimshell.vim'

  call plug#end()
" }

" Fixes {
  if has('autocmd')
    filetype plugin indent on
  endif
  if has('syntax') && !exists('g:syntax_on')
    syntax enable
  endif
" }

" General {
  " Map the leader key to space
  let mapleader="\<SPACE>"
  set background=dark
  colorscheme gruvbox
  set backspace=indent,eol,start      " Allow backspace over everything in insert mode.
  set guifont=Monaco:h12
  set noswapfile
  set smarttab
  set secure
  set exrc
  set ttyfast
  set noautoindent        " I indent my code myself.
  set nocindent           " I indent my code myself.
  set omnifunc=syntaxcomplete#Complete
  set nrformats-=octal
  set ttimeout
  set ttimeoutlen=100
" }

" Search {
  set hlsearch            " Highlight search results.
  set ignorecase          " Make searching case insensitive
  set smartcase           " ... unless the query has capital letters.
  set incsearch           " Incremental search.
  set gdefault            " Use 'g' flag by default with :s/foo/bar/.
  set magic               " Use 'magic' patterns (extended regular expressions).
" }

" Formatting {
  set showcmd             " Show (partial) command in status line.
  set showmatch           " Show matching brackets.
  set showmode            " Show current mode.
  set ruler               " Show the line and column numbers of the cursor.
  set number              " Show the line numbers on the left side.
  set formatoptions+=o    " Continue comment marker in new lines.
  set textwidth=0         " Hard-wrap long lines as you type them.
  set expandtab           " Insert spaces when TAB is pressed.
  set tabstop=2           " Render TABs using this many spaces.
  set shiftwidth=2        " Indentation amount for < and > commands.
  set noerrorbells        " No beeps.
  set modeline            " Enable modeline.
  set esckeys             " Cursor keys in insert mode.
  set linespace=0         " Set line-spacing to minimum.
  set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
  set splitbelow          " Horizontal split below current.
  set splitright          " Vertical split to right of current.
  set autoread            " If file updates, load automatically.
  au! BufWritePost .vimrc so %
  au! BufWritePost .gvimrc so %

  set display+=lastline
  set nostartofline       " Do not jump to first character with page commands.

  if &encoding ==# 'latin1' && has('gui_running')
    set encoding=utf-8
  endif
" }

" Configuration {
  if has('path_extra')
    setglobal tags-=./tags tags^=./tags;
  endif

  " Remove special characters for filename
  set isfname-=:
  set isfname-==
  set isfname-=+

  " Map ; to :
  nnoremap ; :

  if &history < 1000
    set history=1000      " Number of lines in command history.
  endif

  if &tabpagemax < 50
    set tabpagemax=50     " Maximum tab pages.
  endif

  if &undolevels < 200
    set undolevels=200    " Number of undo levels.
  endif

  " Path/file expansion in colon-mode.
  set wildmenu
  set wildmode=list:longest
  set wildchar=<TAB>

  if !empty(&viminfo)
    set viminfo^=!        " Write a viminfo file with registers.
  endif

  set sessionoptions-=options

  " Allow color schemes to do bright colors without forcing bold.
  if &t_Co == 8 && $TERM !~# '^linux'
    set t_Co=16
  endif

  " Remove trailing spaces before saving text files
  " http://vim.wikia.com/wiki/Remove_trailing_spaces
  autocmd BufWritePre * :call StripTrailingWhitespace()
  function! StripTrailingWhitespace()
    if !&binary && &filetype != 'diff'
      normal mz
      normal Hmy
      if &filetype == 'mail'
  " Preserve space after e-mail signature separator
        %s/\(^--\)\@<!\s\+$//e
      else
        %s/\s\+$//e
      endif
      normal 'yz<Enter>
      normal `z
    endif
  endfunction

  " Diff options
  set diffopt+=iwhite

  "Enter to go to EOF and backspace to go to start
  nnoremap <CR> G
  nnoremap <BS> gg
  " Stop cursor from jumping over wrapped lines
  nnoremap j gj
  nnoremap k gk
  " Make HOME and END behave like shell
  inoremap <C-E> <End>
  inoremap <C-A> <Home>
" }

" GUI Options {
  set guioptions-=m " Removes top menubar
  set guioptions-=T " Removes top toolbar
  set guioptions-=r " Removes right hand scroll bar
  set go-=L " Removes left hand scroll bar

  "Toggle menubar
  nnoremap <leader>m :if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>

  " Relative numbering
  function! NumberToggle()
    if(&relativenumber == 1)
      set nornu
      set number
    else
      set rnu
    endif
  endfunc

  " Toggle between normal and relative numbering.
  nnoremap <leader>r :call NumberToggle()<cr>

  " Sets a status line. If in a Git repository, shows the current branch.
  " Also shows the current file name, line and column number.
  if has('statusline')
    set laststatus=2

    " Broken down into easily includeable segments
    set statusline=%<%f\                     " Filename
    set statusline+=%w%h%m%r                 " Options
    "set statusline+=%{fugitive#statusline()} " Git Hotness
    set statusline+=\ [%{&ff}/%Y]            " Filetype
    set statusline+=\ [%{getcwd()}]          " Current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
  endif
" }

" Keybindings {
  " Save file
  nnoremap <Leader>w :w<CR>
  "Copy and paste from system clipboard
  vmap <Leader>y "+y
  vmap <Leader>d "+d
  nmap <Leader>p "+p
  nmap <Leader>P "+P
  vmap <Leader>p "+p
  vmap <Leader>P "+P
  nmap <F8> :TagbarToggle<CR>
  " Indent lines with cmd+[ and cmd+]
  nmap <D-]> >>
  nmap <D-[> <<
  vmap <D-[> <gv
  vmap <D-]> >gv
  noremap <Leader>h :<C-u>split<CR>
  "duplicate line cmd-d
  map <D-d> yyp
" }

" Plug Settings {
  " Lightline {
    let g:lightline = { 'colorscheme': 'gruvbox' }
  " }

  " CtrlP {
    " Open file menu
    nnoremap <Leader>o :CtrlP<CR>
    " Open buffer menu
    nnoremap <Leader>b :CtrlPBuffer<CR>
    " Open most recently used files
    nnoremap <Leader>f :CtrlPMRUFiles<CR>
  " }

  " NERDTree {
    let g:nerdtree_tabs_open_on_gui_startup=0
    " let g:nerdtree_tabs_focus_on_files=1
    let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
    let g:NERDTreeWinSize = 50
    map <C-u> :NERDTreeTabsToggle<CR>
    nmap <C-c> :NERDTreeCWD<CR>
  " }

  " VimShell {
    map <C-s> <Plug>(vimshell_split_switch)
  " }
" }
