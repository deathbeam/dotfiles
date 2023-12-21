# dotfiles

These are my configuration files for Linux. It is still work in
progress, so expect a lot of changes, but I think it is stable enough to be
usable.
My Vim configuration is great for Java and Typescript development when
running Vim in Tmux and using Git. So, if you are doing all of this, then feel
free to steal some stuff from here.

![Screenshot](http://i.imgur.com/z6heJf8.png)

## Requirements

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - Most of
  the installation process is managed via Git, so you need this one.
* [stow](https://www.gnu.org/software/stow/) - Stow is used for dotfile
  installation (creating symlinks)

## How to install?

It is simple, just use `make`

    git clone git://github.com/deathbeam/dotfiles ~/.dotfiles
    cd ~/.dotfiles
    make

Most of my dotfiles are using [Terminus](http://terminus-font.sourceforge.net/)
font, so to make everything look correct, install it in both TrueType and bitmap
format.

## How to update?

You can just use Git:

    cd ~/.dotfiles
    git pull --rebase
    make

## How to inlude your own stuff?

After you have installed dotfiles, you can start including your own stuff by
creating appropriate `.local` dotfiles in home directory:

    $EDITOR ~/.gitconfig.local
    $EDITOR ~/.vimrc.local
    $EDITOR ~/.profile.local
    $EDITOR ~/.zshrc.local
    $EDITOR ~/.tmux.conf.local

To add your own Vim, Tmux or Zsh plugin you can just clone it to proper
`bundle/local` directory:

    # Add SuperTab vim plugin
    git clone git://github.com/ervandew/supertab \
      ~/.vim/pack/local/start/supertab

    # Add Tmux sessionist plugin
    git clone git://github.com/tmux-plugins/tmux-sessionist \
      ~/.tmux/pack/local/start/tmux-sessionist

    # Add zsh-autoenv zsh plugin
    git clone git://github.com/Tarrasch/zsh-autoenv \
      ~/.zsh/pack/local/start/zsh-autoenv

## Included stuff

- [/zsh/.zsh/pack/bundle/start](/zsh/.zsh/pack/bundle/start) ZSH plugins
- [/tmux/.tmux/pack/bundle/start](/tmux/.tmux/pack/bundle/start) TMUX plugins
- [/vim/.vim/pack/bundle/start](/vim/.vim/pack/bundle/start) VIM plugins
