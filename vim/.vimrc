" vim:foldmethod=marker:set ft=vim:

" General {{{

" Reset all auto commands
augroup VimRc
  autocmd!
augroup END

" Enable some default plugins
runtime defaults.vim
runtime macros/matchit.vim
let loaded_matchparen = 1 " disable matchparen, can be really slow

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
  set clipboard=unnamedplus
endif

" }}}

" User interface {{{

" Faster screen redrawing
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

" Better completion menu
set completeopt=longest,menuone

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

" Less annoying errors
set shortmess=at
set noerrorbells
set novisualbell
set t_vb=
set timeoutlen=500

" Always show the status line
set laststatus=2

" Status line format
set statusline=
set statusline +=\ %n\             "buffer number
set statusline +=%{&ff}            "file format
set statusline +=%y                "file type
set statusline +=\ %<%F            "full path
set statusline +=%m                "modified flag
set statusline +=%=%5l             "current line
set statusline +=/%L               "total lines
set statusline +=%4v\              "virtual column number
set statusline +=0x%04B\           "character under cursor

" Always use vertical diffs
set diffopt+=vertical

" Cursor line (it is slowing Vim a bit, but too useful)
set cursorline

" Disable text wrap
set nowrap

" Use old regexpengine (maybe better performance)
set regexpengine=1

" Limit horizontal and vertical syntax rendering (for better performance)
syntax sync minlines=256
set synmaxcol=256

" Automatically rebalance windows on vim resize
autocmd VimRc VimResized * :wincmd =

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

" Colors {{{

" Enable 256 color mode
set t_Co=256

" Set dark background
set background=dark

" Adjust syntax highlighting
autocmd VimRc BufEnter * call AdjustHighlighting()
function! AdjustHighlighting()
  " Make all these colors less annoying
  highlight clear LineNr
  highlight clear SignColumn
  highlight clear FoldColumn
  highlight Search cterm=NONE ctermfg=0 ctermbg=3
  highlight StatusLine ctermbg=NONE ctermfg=4
  highlight StatusLineNC cterm=underline ctermbg=NONE ctermfg=19
  highlight VertSplit ctermbg=NONE ctermfg=19
  highlight Title ctermfg=19
  highlight TabLineSel ctermbg=NONE ctermfg=4
  highlight TabLineFill ctermbg=NONE ctermfg=19
  highlight TabLine ctermbg=NONE ctermfg=19
endfunction

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

" Mappings {{{

" With a map leader it's possible to do extra key combinations
let mapleader = ' '
let maplocalleader = ' '
let g:mapleader = ' '

" Clear last search highlight
map <leader><cr> :noh<cr>

" Quickfix and location list
nmap <silent> <leader>oc  :copen<CR>
nmap <silent> <leader>ol  :lopen<CR>

" Emacs like keybindings for the command line (:) are better
" and we cannot use Vi style-binding here anyway, because ESC
" just closes the command line and using Home and End.. just no, f.e. OSX keyboards
" do not even have them, because they are useless.
cnoremap <C-A>    <Home>
cnoremap <C-E>    <End>
cnoremap <C-K>    <C-U>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W w !sudo tee % > /dev/null

" }}}

" Plugins {{{

" Modify runtime path
set rtp+=~/.fzf
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
execute pathogen#infect('~/.vim/bundle/local/{}')
execute pathogen#helptags()

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

" Obsession
function! Session()
  " If session file exists, source it, and then start session recording
  if filereadable('Session.vim')
    source Session.vim
  endif

  :Obsession
endfunction
command! -bar Session :call Session()

" Ultisnips
let g:UltiSnipsExpandTrigger = '<s-tab>'

" Completor
let g:completor_auto_trigger = 0
let g:completor_min_chars = 1

" VimWiki
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext=0
let g:vimwiki_table_mappings = 0

" EditorConfig
let g:EditorConfig_core_mode = 'external_command' " Speed up editorconfig plugin
let g:EditorConfig_exclude_patterns = ['fugitive://.*'] " Fix EditorConfig for fugitive

" Fugitive
autocmd VimRc BufReadPost fugitive://* set bufhidden=delete
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gl :Glog<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gr :Gremove<CR>

" Syntastic
nmap <silent> <leader>mf :SyntasticCheck<CR>
nmap <silent> <leader>mF :make<CR>
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_wq = 0
set statusline+=%#warningmsg#%{SyntasticStatuslineFlag()}%*

" Vim Test
let test#strategy = 'make'
nmap <silent> <leader>mt :TestFile<CR>
nmap <silent> <leader>mT :TestSuite<CR>
nmap <silent> <leader>mtt :TestNearest<CR>

" FZF {{{

" Fuzzy completion
function! FuzzyCompleteFunc(findstart, base)
  let Func = function(get(g:, 'fuzzyfunc', &omnifunc))
  let results = Func(a:findstart, a:base)

  if a:findstart
    return results
  endif

  if type(results) == type({}) && has_key(results, 'words')
    let l:words = []
    for result in results.words
      call add(words, result.word . ' ' . result.menu)
    endfor
  elseif len(results)
    let l:words = results
  endif

  if len(l:words)
    let result = fzf#run({ 'source': l:words, 'down': '~40%', 'options': printf('--query "%s" +s', a:base) })

    if empty(result)
      return [ a:base ]
    endif

    return [ split(result[0])[0] ]
  else
    return [ a:base ]
  endif
endfunction

let g:fuzzyfunc = 'completor#completefunc'

" Custom trigger for our fuzzy function
function! FuzzyFuncTrigger()
  setlocal completefunc=FuzzyCompleteFunc
  setlocal completeopt=menu
  call feedkeys("\<c-x>\<c-u>", 'n')
endfunction

imap <c-x><c-j> <c-o>:call FuzzyFuncTrigger()<cr>

" Awesome TAB fuzzy completion
function! TabComplete()
  let col = col('.') - 1

  if !col || getline('.')[col - 1] !~# '\k'
    call feedkeys("\<tab>", 'n')
    return
  endif

  call feedkeys("\<c-x>\<c-j>")
endfunction

inoremap <silent> <tab> <c-o>:call TabComplete()<cr>

" Try to use ripgrep, otherwise fallback to ag
function! s:fzf_rg(query, ...)
  if executable('rg')
    let query = empty(a:query) ? '^.' : a:query
    let args = copy(a:000)
    let opts = len(args) > 1 ? remove(args, 0) : ''
    let command = opts . ' ' . "'".substitute(query, "'", "'\\\\''", 'g')."'"
    return call('fzf#vim#grep', extend(['rg --no-heading --column --color always '.command, 1], args))
  endif

  return call('fzf#vim#ag', insert(copy(a:000), a:query, 0))
endfunction

command! -bang -nargs=* Find call s:fzf_rg(<q-args>, <bang>0)

nmap <leader>/ :Find<cr>
nmap <leader>T :Tags<cr>
nmap <leader>t :BTags<cr>
nmap <leader>F :Files<cr>
nmap <leader>f :GFiles<cr>
nmap <leader>a :Commands<cr>
nmap <leader>h :History<cr>
nmap <leader>b :Buffers<cr>
nmap <leader>w :Windows<cr>
nmap <leader>s :Snippets<cr>
nmap <leader>c :Commits<cr>
nmap <leader>? :Helptags<cr>
" }}}

" }}}

" User configuration {{{

try
  " Load user configuration
  source ~/.vimrc.local
catch
endtry

" }}}
