#!/bin/bash

echo "Starting installation. Patience you must have my young padawan."

ADTRC_HOME=~/.awesomedotrc
ADTRC_RCS="$ADTRC_HOME/dotrcs"
ADTRC_USER="$ADTRC_HOME/user"
ADTRC_LIB="$ADTRC_HOME/.lib"
cd $ADTRC_HOME

# Install bash-it if not installed
[[ ! -d $ADTRC_LIB/bashit ]] &&
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $ADTRC_LIB/bashit &&
  echo y | bash $ADTRC_LIB/bashit/install.sh

# Install z.sh if not installed
[[ ! -d $ADTRC_LIB/z ]] &&
  git clone https://github.com/rupa/z $ADTRC_LIB/z

# Install Plug
[[ ! -d $ADTRC_LIB/autoload ]] &&
  git clone https://github.com/junegunn/vim-plug $ADTRC_LIB/autoload

# Install Bash config
echo "source $ADTRC_RCS/bashrc
[[ -f $ADTRC_USER/bashrc ]] && source $ADTRC_USER/bashrc
" >> ~/.bashrc

# Install Vim config
echo "set runtimepath+=$ADTRC_LIB
let g:plug_home=fnamemodify(expand('$ADTRC_LIB/plugged'), ':p')
source $ADTRC_RCS/vimrc
try
source $ADTRC_USER/vimrc
catch
endtry
" > ~/.vimrc

# Install Vim plugins
vim +PlugInstall +qall

# Fix MacVim fullscreen mode
command -v mvim >/dev/null 2>&1 && defaults write org.vim.MacVim MMNativeFullScreen 0

# Make NeoVim use same config as Vim
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
mkdir -p $ADTRC_LIB/autoload
ln -s ~/.vimrc ~/.config/nvim/init.vim

[[ ! $TERM == "dumb" ]] && bash
