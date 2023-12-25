" vim:foldmethod=marker:set ft=vim:

" General {{{

" Reset all auto commands
augroup VimRc
  autocmd!
augroup END

" Enable some default plugins
runtime defaults.vim
runtime macros/matchit.vim

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

" use syntax complete if nothing else available
autocmd VimRc Filetype *
      \  if &omnifunc == ""
      \|   setlocal omnifunc=syntaxcomplete#Complete
      \| endif

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

" Faster screen redrawing (do not set as default when in not common terminals)
set ttyfast

" after leaving buffer set it as hidden (so we can open buffer without saving
" previous buffer)
set hidden

" display completion matches in a status line
set wildmode=list:longest,list:full

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.class
if has('win16') || has('win32')
  set wildignore+=.git\*,.hg\*,.svn\*
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Allows cursor change
if has('nvim')
  " visible incremental command replace
  set inccommand=nosplit
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
elseif exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Include spelling completion when spelling enabled
set complete+=kspell

" Includes completion is super slow, disable it
set complete-=i

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch

" Always show some lines under
set scrolloff=8

" Fast update
set updatetime=50

" Less annoying errors
set noerrorbells
set novisualbell
set t_vb=
set timeout
set timeoutlen=500

" Always show the status line
set laststatus=2

" Status line format
set statusline=
set statusline+=\ %{&ff}                "file format
set statusline+=%y                      "file type
set statusline+=\ %<%F                  "full path
set statusline+=\ %m                    "modified flag
set statusline+=%1*%=                   "left/right separator
set statusline+=%2*\ [%l/%L-%v\ 0x%04B] "cursor info

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

" Colors {{{

" Adjust syntax highlighting
autocmd VimRc BufEnter * call AdjustHighlighting()
function! AdjustHighlighting()
  " Make all these colors less annoying
  highlight clear LineNr
  highlight clear SignColumn
  highlight clear FoldColumn
  highlight Search cterm=NONE ctermfg=0 ctermbg=3
  highlight StatusLine cterm=underline ctermbg=4 ctermfg=0
  highlight StatusLineNC cterm=underline ctermbg=NONE ctermfg=19
  highlight VertSplit ctermbg=NONE ctermfg=19
  highlight Title ctermfg=19
  highlight TabLineSel ctermbg=NONE ctermfg=4
  highlight TabLineFill ctermbg=NONE ctermfg=19
  highlight TabLine ctermbg=NONE ctermfg=19
  hi User1 ctermfg=6 cterm=underline ctermbg=NONE
  hi User2 ctermfg=2 cterm=underline ctermbg=NONE
  hi User3 ctermfg=5 cterm=underline ctermbg=NONE
  hi User4 ctermfg=3 cterm=underline ctermbg=NONE
endfunction
call AdjustHighlighting()

" }}}

" Text, tab and indent related {{{

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

" Text width is 80 characters
set textwidth=80

" Better automatic indentation
set autoindent
set smartindent

" For regular expressions turn magic on
set magic

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

" }}}

" Plugins {{{

" VimWiki
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext=0
let g:vimwiki_table_mappings = 0

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

" EditorConfig
let g:EditorConfig_core_mode = 'vim_core' " External mode got removed for some reason
let g:EditorConfig_exclude_patterns = ['fugitive://.*'] " Fix EditorConfig for fugitive

" Load all plugins
:packloadall

" If base16 theme is set from shell, load it
if filereadable(expand('~/.vimrc_background'))
  let base16colorspace=256
  source ~/.vimrc_background
else
  " Set theme if possible
  try
    colorscheme base16-solarized-dark
  catch
  endtry
endif

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
set statusline+=%3*\ %{fugitive#statusline()}
set statusline+=%4*%{StatuslineLsp()}

" Finder
nmap <leader>fg :RG<cr>
nmap <leader>ff :Files<cr>
nmap <leader>fF :GFiles<cr>
nmap <leader>fa :Commands<cr>
nmap <leader>fc :Commits<cr>
nmap <leader>fb :Buffers<cr>
nmap <leader>fh :History<cr>
nmap <leader>fo :LS ~/git<cr>

command! -bang -complete=dir -nargs=? LS
    \ call fzf#run(fzf#wrap('ls', {'source': 'ls', 'dir': <q-args>}, <bang>0))

" }}}

" User configuration {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
