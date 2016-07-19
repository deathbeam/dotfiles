#!/bin/bash

# Check for NeoVim installation
command -v nvim >/dev/null 2>&1 || { echo >&2 "NeoVim is not installed. Visit https://github.com/neovim/neovim/wiki/Installing-Neovim."; exit 1; }

# Install Plug for NeoVim
PLUG_PATH=~/.config/nvim/autoload/plug.vim 
if [ ! -f $PLUG_PATH ]; then
	curl -fLo --create-dirs $PLUG_PATH https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
