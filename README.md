# awesome.rc
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/awesomedotrc.svg?branch=master)](https://travis-ci.org/deathbeam/awesomedotrc)

This is my Bash and Vim configuration. It is still work in progress, so expect a lot of changes, but I think it is stable enough to be usable.

## Requirements

* bash - This is Bash and Vim config anyway, duh
* vim - Same as above. Requires to be installed with python support for all plugins to work correctly
* git - Most of the installation process is managed via Git
* editorconfig - For editorconfig plugin

## How to install?

It is simple, just use integrated dotbot installer

```shell
git clone https://github.com/deathbeam/awesomedotrc.git ~/.awesomedotrc && \
    ~/.awesomedotrc/install
```

I recommend to install [Hack for Powerline](https://github.com/powerline/fonts/tree/master/Hack) font. It is awesome for programming and also supports special symbols used in Bash theme we are using here and Vim config is also configured to try to use it when available.

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

To add your own Vim plugin, just clone it to `$ARC/usr/vim` directory. For example to add [SuperTab](https://github.com/ervandew/supertab), all you need to do is run this command:

```shell
git clone https://github.com/ervandew/supertab.git $ARC/usr/vim/supertab
```

## Included stuff

### Bash
 * [fasd](https://github.com/clvv/fasd): Command-line productivity booster, offers quick access to files and directories, inspired by autojump, z and v.
 * [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder written in Go
 * [base-16-shell](https://github.com/chriskempson/base16-shell): A shell script to change your shell's default ANSI colors but most importantly, colors 17 to 21 of your shell's 256 colorspace (if supported by your terminal)

### Vim
 * [base16-vim](https://github.com/chriskempson/base16-vim): Base16 for Vim
 * [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim): EditorConfig plugin for Vim
 * [fzf.vim](https://github.com/junegunn/fzf.vim): fzf :heart: vim
 * [gist-vim](https://github.com/mattn/gist-vim): vimscript for creating gists
 * [hardmode](https://github.com/wikitopian/hardmode): Vim: Hard Mode
 * [incsearch](https://github.com/haya14busa/incsearch.vim): Improved incremental searching for Vim
 * [pathogen.vim](https://github.com/tpope/vim-pathogen): Manage your runtimepath
 * [syntastic](https://github.com/scrooloose/syntastic): Syntax checking hacks for vim
 * [ultisnips](https://github.com/SirVer/ultisnips): The ultimate snippet solution for Vim
 * [undotree](https://github.com/mbbill/undotree): The ultimate undo history visualizer for VIM
 * [vim-airline](https://github.com/vim-airline/vim-airline): Lean & mean status/tabline for vim that's light as air
 * [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes): A collection of themes for vim-airline
 * [vim-commentary](https://github.com/tpope/vim-commentary): comment stuff out
 * [vim-easymotion](https://github.com/easymotion/vim-easymotion): Vim motions on speed!
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so awesome, it should be illegal
 * [vim-gitgutter](https://github.com/airblade/vim-gitgutter): A Vim plugin which shows a git diff in the gutter (sign column) and stages/undoes hunks
 * [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors): True Sublime Text style multiple selections for Vim
 * [vim-repeat](https://github.com/tpope/vim-repeat): enable repeating supported plugin maps with "."
 * [vim-rooter](https://github.com/airblade/vim-rooter): Changes Vim working directory to project root (identified by presence of known directory or file)
 * [vim-snippets](https://github.com/honza/vim-snippets): contains snippets files for various programming languages
 * [vim-startify](https://github.com/mhinz/vim-startify): The fancy start screen for Vim
 * [vim-surrond](https://github.com/tpope/vim-surround): quoting/parenthesizing made simple
 * [vim-vinegar](https://github.com/tpope/vim-vinegar): combine with netrw to create a delicious salad dressing
 * [vim-wiki](https://github.com/vimwiki/vimwiki): Personal Wiki for Vim
 * [webapi-vim](https://github.com/mattn/webapi-vim): vim interface to Web API

### Tmux
 * [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible): basic tmux settings everyone can agree on
 * [tmux-gitbar](https://github.com/aurelien-rainone/tmux-gitbar): Git in your tmux status bar
 * [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight): Visually shows different tmux modes (prefix, copy)
 * [tmux-yank](https://github.com/tmux-plugins/tmux-yank): Plugin for copying to system clipboard
 * [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat): Enhances tmux search
 * [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect): Persists tmux environment across system restarts
 * [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum): Continuous saving of tmux environment. Automatic restore when tmux is started. Automatic tmux start when computer is turned on.
