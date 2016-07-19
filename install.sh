#!/bin/bash

# Check for NeoVim installation
echo "Checking for NeoVim installation..."
command -v nvim >/dev/null 2>&1 || { echo >&2 "NeoVim is not installed. Visit https://github.com/neovim/neovim/wiki/Installing-Neovim."; exit 1; }

# Install Plug for NeoVim
echo "Installing Plug for NeoVim..."
PLUG_PATH=~/.config/nvim/autoload/plug.vim 
if [ ! -f $PLUG_PATH ]; then
	curl -fLo --create-dirs $PLUG_PATH https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Copy config files
echo "Copying config files..."
cp .zshrc ~/.zshrc
cp .config/nvim/init.vim ~/.config/nvim/init.vim

# Install all Plug plugins
echo "Installing NeoVim plugins..."
nvim +PlugInstall +qall

echo "Installation done."
