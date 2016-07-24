#!/bin/bash

ADTRC_HOME=~/.awesomedotrc
ADTRC_RCS="$ADTRC_HOME/dotrcs"
ADTRC_USER="$ADTRC_HOME/user"
ADTRC_LIB="$ADTRC_HOME/.lib"

cd $ADTRC_HOME

# Install ZSH config
echo "source $ADTRC_RCS/zshrc
[[ -f $ADTRC_USER/config.zsh ]] && source $ADTRC_USER/zshrc
" > ~/.zshrc

# Install Prezto config
echo "source $ADTRC_RCS/zpreztorc
[[ -f $ADTRC_USER/prezto.zsh ]] && source $ADTRC_USER/prezto.zsh
" > ~/.zpreztorc

# Install Vim config
echo "set runtimepath+=$ADTRC_LIB
source $ADTRC_RCS/vimrc
try
source $ADTRC_USER/vimrc
catch
endtry
" > ~/.vimrc

# Make NeoVIM use same config as VIM
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
mkdir -p $ADTRC_LIB/autoload
ln -s $ADTRC_LIB/autoload ~/.config/nvim/autoload
ln -s ~/.vimrc ~/.config/nvim/init.vim

echo "Installation done. Enjoy :)"
[[ ! $TERM == "dumb" ]] && zsh
