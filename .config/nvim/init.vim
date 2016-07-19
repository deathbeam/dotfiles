" plugins
call plug#begin()
Plug 'VundleVim/Vundle.vim'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'altercation/vim-colors-solarized'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'vim-scripts/TaskList.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
call plug#end()

" key maps
map <C-n> :NERDTreeToggle<CR>

" lightline
let g:lightline = { 'colorscheme': 'solarized_dark' }
set laststatus=2

" solarized dark
set number
set background=dark
colorscheme solarized

" nerdree
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
