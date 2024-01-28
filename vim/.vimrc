" vim:foldmethod=marker:set ft=vim:

" General {{{

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
set undodir=$HOME/.vim/undodir
set undofile

" Use system clipboard
if has('clipboard')
  set clipboard=unnamed
endif

" }}}

" User interface {{{

" set title
set title
set titlestring=%F

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Show matching brackets when text indicator is over them
set showmatch

" Always show some lines under
set scrolloff=8

" Always show the status line
set laststatus=2

" Status line format
set statusline=
set statusline+=%1*\ %{&ff}                "file format
set statusline+=%y                      "file type
set statusline+=\ %<%F                  "full path
set statusline+=\ %m                    "modified flag
set statusline+=%2*%=                   "left/right separator
set statusline+=%3*\ [%l/%L-%v\ 0x%04B] "cursor info

" Always use vertical diffs
set diffopt+=vertical

" Cursor line (it is slowing Vim a bit, but too useful)
set cursorline

" Disable text wrap
set nowrap

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Automatically rebalance windows on vim resize
autocmd VimRc VimResized * :wincmd =

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

" Restore cursor position
autocmd BufRead * autocmd FileType <buffer> ++once
      \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif

" With a map leader it's possible to do extra key combinations
let mapleader = ' '
let maplocalleader = ' '
let g:mapleader = ' '

" Splits
noremap <silent> <leader>" :<C-U>vsplit<cr>
noremap <silent> <leader>% :<C-U>split<cr>
noremap <silent> <leader>x :<C-U>quit<cr>

" Emacs like keybindings for the command line (:) are better
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Useful system mappings
command! W w !sudo tee % > /dev/null
command! X !chmod +x % > /dev/null

function! ToggleZoom(zoom)
  if exists("t:restore_zoom") && (a:zoom == v:true || t:restore_zoom.win != winnr())
      exec t:restore_zoom.cmd
      unlet t:restore_zoom
  elseif a:zoom
      let t:restore_zoom = { 'win': winnr(), 'cmd': winrestcmd() }
      exec "normal \<C-W>\|\<C-W>_"
  endif
endfunction

augroup restorezoom
    au WinEnter * silent! :call ToggleZoom(v:false)
augroup END
nnoremap <silent> <leader>z :call ToggleZoom(v:true)<CR>

" }}}

" Plugins {{{

" VimWiki
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext = 0
let g:vimwiki_table_mappings = 0
autocmd BufEnter diary.md :VimwikiDiaryGenerateLinks

" Vim rooter
let g:rooter_patterns = [
      \ '.git',
      \ '.git/',
      \ '_darcs/',
      \ '.hg/',
      \ '.bzr/',
      \ '.svn/',
      \ '.pylintrc',
      \ 'pylintrc',
      \ 'package.json',
      \ '.editorconfig',
      \ 'requirements.txt',
      \]

" Load all plugins
:packloadall

" }}}

" User configuration {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
