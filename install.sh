#!/bin/bash

echo "Starting installation. Patience you must have my young padawan."

# Small helper to write and backup rcs
process_rc() {
  local rc="$HOME/$1"

  # Backup rc file if exists
  [[ -f "$rc" ]] && cp -R "$rc" "$rc.bak"

  # Write new rc file
  echo "$2" > "$rc"
}

# Some helper variables
ARC_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ARC_RCS="$ARC_HOME/dotrcs"
ARC_USER="$ARC_HOME/user"
ARC_LIB="$ARC_HOME/.lib"

# Create and use proper directory structure
mkdir -p $ARC_LIB
mkdir -p $ARC_USER
cd $ARC_HOME

# Install bash-it
[[ ! -d $ARC_LIB/bashit ]] &&
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $ARC_LIB/bashit &&
  bash $ARC_LIB/bashit/install.sh -s

# Install qfc
[[ ! -d $ARC_LIB/qfc ]] &&
  git clone https://github.com/pindexis/qfc $ARC_LIB/qfc

# Install z.sh
[[ ! -d $ARC_LIB/z ]] &&
  git clone https://github.com/rupa/z $ARC_LIB/z

# Install Plug
[[ ! -d $ARC_LIB/autoload ]] &&
  git clone https://github.com/junegunn/vim-plug $ARC_LIB/autoload

# Create bash config
process_rc .bash_profile "
source \"$HOME/.bashrc\"

# Awesome Star Wars MOTD
motd() {
  local motd[1]=\$(echo \"\$USER, I am your father.\" | cowsay -f vader-koala)
  local motd[2]=\$(echo \"\$USER told me enough! \$USER told me you killed him!\" | cowsay -f luke-koala)
  local rand=\$[\$RANDOM % 2 + 1]
  echo -e \"\033[33m\${motd[\$rand]}\033[0m\n\"
  echo -e \"Run \033[33mmotd\033[0m to show this MOTD!\"
  echo -e \"Run \033[33mstarwars\033[0m to watch some Star Wars!\"
}

motd
"
process_rc .bashrc "
ARC_HOME=$ARC_HOME
ARC_USER=$ARC_USER
ARC_LIB=$ARC_LIB

source \"$ARC_RCS/bashrc\"
[[ -f \"$ARC_USER/bashrc\" ]] &&
  source \"$ARC_USER/bashrc\"
"

# Create Vim config
process_rc .vimrc "
set runtimepath+=$ARC_LIB
let \$ARC_USER='$ARC_USER'
let g:plug_home=fnamemodify(expand('$ARC_LIB/plugged'), ':p')

source $ARC_RCS/vimrc
try
source $ARC_USER/vimrc
catch
endtry
"

# Install Vim plugins
vim +PlugInstall +qall

# Fix MacVim fullscreen mode
command -v mvim >/dev/null 2>&1 &&
  defaults write org.vim.MacVim MMNativeFullScreen 0

# Make NeoVim use same config as Vim
rm -rf $HOME/.config/nvim
mkdir -p $HOME/.config/nvim
mkdir -p $ARC_LIB/autoload
ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim

echo "Installation complete. May the Force be with you."
# Reload terminal after installation
[[ ! $TERM == "dumb" ]] && bash
