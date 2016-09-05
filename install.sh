#!/bin/bash

echo "Starting installation. Patience you must have my young padawan."

ARC_HOME=$HOME/.awesomedotrc
ARC_RCS="$ARC_HOME/dotrcs"
ARC_USER="$ARC_HOME/user"
ARC_LIB="$ARC_HOME/.lib"
mkdir -p $ARC_LIB
mkdir -p $ARC_USER

cd $ARC_HOME

# Install bash-it if not installed
[[ ! -d $ARC_LIB/bashit ]] &&
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $ARC_LIB/bashit &&
  echo y | bash $ARC_LIB/bashit/install.sh

# Install z.sh if not installed
[[ ! -d $ARC_LIB/z ]] &&
  git clone https://github.com/rupa/z $ARC_LIB/z

# Install Plug
[[ ! -d $ARC_LIB/autoload ]] &&
  git clone https://github.com/junegunn/vim-plug $ARC_LIB/autoload

# Install Bash config
echo "
[[ -f $ARC_USER/bashitrc ]] &&
  source $ARC_USER/bashitrc

[[ -z \"\$BASH_IT\" ]] &&
  export BASH_IT=\"$ARC_LIB/bashit\"
[[ -z \"\$BASH_IT_THEME\" ]] &&
  export BASH_IT_THEME='minimal'
[[ -z \"\$SCM_CHECK\" ]] &&
  export SCM_CHECK=true

source \$BASH_IT/bash_it.sh
source $HOME/.bashrc
" > $HOME/.bash_profile

echo "
ARC_HOME=$ARC_HOME
ARC_USER=$ARC_USER
ARC_LIB=$ARC_LIB

source $ARC_RCS/bashrc
[[ -f $ARC_USER/bashrc ]] &&
  source $ARC_USER/bashrc
" > $HOME/.bashrc

# Install Vim config
echo "
set runtimepath+=$ARC_LIB
let \$ARC_USER='$ARC_USER'
let g:plug_home=fnamemodify(expand('$ARC_LIB/plugged'), ':p')

source $ARC_RCS/vimrc
try
source $ARC_USER/vimrc
catch
endtry
" > $HOME/.vimrc

# Install Vim plugins
vim +PlugInstall +qall

# Fix MacVim fullscreen mode
command -v mvim >/dev/null 2>&1 &&
  defaults write org.vim.MacVim MMNativeFullScreen 0

# Make NeoVim use same config as Vim
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
mkdir -p $ARC_LIB/autoload
ln -s ~/.vimrc ~/.config/nvim/init.vim

# Reload terminal after installation
[[ ! $TERM == "dumb" ]] && bash
