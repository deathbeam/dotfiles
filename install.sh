#!/bin/bash

cd ~/.awesomedotrc

# Install ZSH config
echo 'source ~/.awesomedotrc/dotrcs/zshrc
[[ -f ~/.awesomedotrc/custom/config.zsh ]] && source ~/.awesomedotrc/custom/main.zsh
' > ~/.zshrc

# Install Prezto config
echo 'source ~/.awesomedotrc/dotrcs/zpreztorc
[[ -f ~/.awesomedotrc/custom/prezto.zsh ]] && source ~/.awesomedotrc/custom/prezto.zsh
' > ~/.zpreztorc

# Install VIM config
echo 'source ~/.awesomedotrc/dotrcs/vimrc
try
source ~/.awesomedotrc/custom/main.vim
catch
endtry
' > ~/.vimrc

# Make NeoVIM use same config as VIM
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
ln -s ~/.vim/autoload ~/.config/nvim/autoload
ln -s ~/.vimrc ~/.config/nvim/init.vim

echo "Installation done. Enjoy :)"
[[ ! $TERM == "dumb" ]] && zsh
