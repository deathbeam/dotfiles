# awesome.rc
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/awesomedotrc.svg?branch=master)](https://travis-ci.org/deathbeam/awesomedotrc)

This is my Bash and Vim configuration. It is still work in progress, so expect a lot of changes, but I think it is stable enough to be usable.

## Requirements

* bash - This is Bash and Vim config anyway, duh
* vim - Same as above. Vim with Lua support is required for everything to work correctly.
* git - Most of the installation process is managed via Git
* lua - Needed for some Vim plugins
* cowsay - Just for fancy MOTD (the most important thing in this entire setup, of course)

## How to install?

It is simple, just use integrated dotbot installer

```shell
git clone https://github.com/deathbeam/awesomedotrc.git ~/.awesomedotrc && \
    ~/.awesomedotrc/install
```

I recommend to install [Hack for Powerline](https://github.com/powerline/fonts/tree/master/Hack) font. It is awesome for programming and also supports special symbols used in Bash theme we are using here and Vim config is also configured to try to use it when available.

Also, it is preferred to use [Tomorrow Night](https://github.com/chriskempson/tomorrow-theme) color scheme for your favorite terminal. It will look a lot better, because Vim is also using this color scheme.

## How to update?

There is nothing simplier, just use git :)

```shell
git -C ~/.awesomedotrc pull --rebase
```

## How to inlude your own stuff?

After you have installed awesomedotrc, you can start including your own stuff by using the `arc` command:

```shell
# Custom bash configuration
arc bashrc

# Custom Vim configuration
arc vimrc

# Custom Tmux configuration
arc tmux.conf
```

To add your owm Vim plugin, just clone it to `$ARC/usr/vim` directory. For example to add [SuperTab](https://github.com/ervandew/supertab), all you need to do is run this command:

```shell
git clone https://github.com/ervandew/supertab.git $ARC/usr/vim/supertab
```

## Included stuff
TODO: Finish included stuff list

### Bash
 * [fasd](https://github.com/clvv/fasd): Command-line productivity booster, offers quick access to files and directories, inspired by autojump, z and v.
 * [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder written in Go
 * [base-16-shell](https://github.com/chriskempson/base16-shell): A shell script to change your shell's default ANSI colors but most importantly, colors 17 to 21 of your shell's 256 colorspace (if supported by your terminal)

### Vim
 * [pathogen.vim](https://github.com/tpope/vim-pathogen): Manage your runtimepath
 * [NERDTree](https://github.com/scrooloose/nerdtree): A tree explorer plugin for vim
 * [unite.vim](https://github.com/Shougo/unite.vim): Unite and create user interfaces
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so awesome, it should be illegal
 * [syntastic](https://github.com/scrooloose/syntastic): Syntax checking hacks for vim
 * [vim-airline](https://github.com/vim-airline/vim-airline): Lean & mean status/tabline for vim that's light as air
 * [undotree](https://github.com/mbbill/undotree): The ultimate undo history visualizer for VIM
 * ...

### Tmux
 * [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible): basic tmux settings everyone can agree on
 * [tmux-gitbar](https://github.com/aurelien-rainone/tmux-gitbar): Git in your tmux status bar
 * [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight): Visually shows different tmux modes (prefix, copy)
 * [tmux-yank](https://github.com/tmux-plugins/tmux-yank): Plugin for copying to system clipboard
 * [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat): Enhances tmux search
 * [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect): Persists tmux environment across system restarts
 * [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum): Continuous saving of tmux environment. Automatic restore when tmux is started. Automatic tmux start when computer is turned on.
