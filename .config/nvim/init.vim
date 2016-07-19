call plug#begin()
Plug 'VundleVim/Vundle.vim'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'altercation/vim-colors-solarized'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
call plug#end()

" lightline
let g:lightline = { 'colorscheme': 'solarized_dark' }
set laststatus=2

" solarized dark
set number
set background=dark
colorscheme solarized

" NERDTree
let NERDTreeShowHidden=1
