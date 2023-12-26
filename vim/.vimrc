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
try
  set undodir=$HOME/.vim/undodir
  set undofile
catch
endtry

" Use system clipboard
if has('clipboard')
  set clipboard=unnamed
endif

" Use faster grep alternatives if possible
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat^=%f:%l:%c:%m
elseif executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --vimgrep
  set grepformat^=%f:%l:%c:%m
endif

" }}}

" User interface {{{

" display completion matches in a status line
set wildmode=list:longest,list:full

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.class
if has('win16') || has('win32')
  set wildignore+=.git\*,.hg\*,.svn\*
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Include spelling completion when spelling enabled
set complete+=kspell

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

" With a map leader it's possible to do extra key combinations
let mapleader = ' '
let maplocalleader = ' '
let g:mapleader = ' '

" Clear last search highlight
map <leader><cr> :noh<cr>

" Splits
noremap <silent> <leader>" :<C-U>vsplit<cr>
noremap <silent> <leader>% :<C-U>split<cr>
noremap <silent> <leader>x :<C-U>quit<cr>

" Emacs like keybindings for the command line (:) are better
" and we cannot use Vi style-binding here anyway, because ESC
" just closes the command line and using Home and End.. just no, f.e. OSX keyboards
" do not even have them, because they are useless.
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W w !sudo tee % > /dev/null
command! X !chmod +x % > /dev/null

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

" Read DOCX
autocmd VimRc BufReadPost *.doc,*.docx,*.rtf,*.odp,*.odt silent %!pandoc "%" -tplain -o /dev/stdout

" Obsession
function! Session()
  " If session file exists, source it, and then start session recording
  if filereadable('Session.vim')
    source Session.vim
  endif

  :Obsession
endfunction
command! -bar Session :call Session()

" Undotree
nnoremap <silent> <leader>u :UndotreeToggle<CR>

" Fugitive
autocmd VimRc BufReadPost fugitive://* set bufhidden=delete
nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gc :Git commit --signoff<CR>
nnoremap <silent> <leader>gb :Git blame<CR>
nnoremap <silent> <leader>gl :Git log<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gr :GRemove<CR>

" Statusline
function! StatuslineLsp() abort
  if luaeval('vim.lsp and #vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction
set statusline+=%4*\ %{fugitive#statusline()}
set statusline+=%5*%{StatuslineLsp()}

" }}}

" User configuration {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
