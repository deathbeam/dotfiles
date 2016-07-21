#!/bin/bash

# ZSH stuff
read -p "Use custom .zshrc? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cp zshrc ~/.zshrc
fi

# Vim stuff
# Check for Vim installation
echo "Checking for Vim installation..."
command -v vim >/dev/null 2>&1 || \
  { echo >&2 "Vim is not installed. Visit http://www.vim.org."; exit 1; }

# Install Plug for NeoVim
echo "Installing Plug for Vim..."
PLUG_PATH=~/.vim/autoload/plug.vim
if [ ! -f $PLUG_PATH ]; then
  curl -fLo $PLUG_PATH --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Copy config files
echo "Copying config files for Vim..."
cp vimrc ~/.vimrc
cp gvimrc ~/.gvimrc

# Install all Plug plugins
echo "Installing Vim plugins..."
vim +PlugInstall +qall

# NeoVim stuff
read -p "Install NeoVim stuff? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  # Check for NeoVim installation
  echo "Checking for NeoVim installation..."
  command -v nvim >/dev/null 2>&1 || \
    { echo >&2 "NeoVim is not installed. Visit https://github.com/neovim/neovim/wiki/Installing-Neovim."; exit 1; }

  # Install Plug for NeoVim
  echo "Installing Plug for NeoVim..."
  PLUG_PATH=~/.config/nvim/autoload/plug.vim
  if [ ! -f $PLUG_PATH ]; then
    mkdir -p ~/.config/nvim/autoload/
    curl -fLo $PLUG_PATH --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  # Copy config files
  echo "Copying config files for NeoVim..."
  mkdir -p ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim

  # Install all Plug plugins
  echo "Installing NeoVim plugins..."
  nvim +PlugInstall +qall
fi

echo "Installation done. Vim cheatsheet: http://vim.rtorr.com"
