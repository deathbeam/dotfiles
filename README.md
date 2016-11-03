# awesome.rc
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/awesomedotrc.svg?branch=master)](https://travis-ci.org/deathbeam/awesomedotrc)

This is my Bash and Vim configuration. It is still work in progress, so expect a lot of changes, but I think it is stable enough to be usable.

## Requirements

* bash - This is Bash and Vim config anyway, duh
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - Most of the installation process is managed via Git

And some optional ones:

* vim - Do not required if you only want bash and tmux stuff, but hey, Vim is awesome. Requires to be installed with python support for all plugins to work correctly
* [vimperator](https://addons.mozilla.org/en-US/firefox/addon/vimperator/) - And Vim in your Firefox is even more awesome
* [Stylish](https://addons.mozilla.org/en-US/firefox/addon/stylish/) - And having your Firefox to look like Vim is even more awesome
* [editorconfig](https://github.com/editorconfig/editorconfig-core-c/blob/master/INSTALL.md) - For editorconfig plugin

## How to install?

It is simple, just use integrated dotbot installer

```shell
git clone https://github.com/deathbeam/awesomedotrc.git ~/.awesomedotrc && \
    ~/.awesomedotrc/install
```

I recommend to install [Hack for Powerline](https://github.com/powerline/fonts/tree/master/Hack) font. It is awesome for programming and also supports special symbols used in Bash theme we are using here and Vim config is also configured to try to use it when available.

To install Firefox theme, use [Stylish](https://addons.mozilla.org/en-US/firefox/addon/stylish/) and enter this URL to `Install from URLs`:

```
https://raw.githubusercontent.com/deathbeam/awesomedotrc/master/lib/firefox/firefox.css
```

## How to update?

You can use

```
adrc --update
```

what was made exactly for this. It will fetch latest changes from remote, then runs rebase and at end run installation script to update links and installed stuff. Or, if you want, you can use Git like this:


```shell
git -C $ADRC pull --rebase
```

## How to inlude your own stuff?

After you have installed awesomedotrc, you can start including your own stuff by using the `adrc --open` command:

```shell
adrc --open bashrc
adrc --open vimrc
adrc --open tmux.conf
```

or manually without helper:

```shell
vim $ADRC/usr/bashrc
vim $ADRC/usr/vimrc
vim $ADRC/usr/tmux.conf
```

To add your own Vim plugin you can use `adrc --vim-plugin` command. For example to add [SuperTab](https://github.com/ervandew/supertab), all you need to do is run this command:

```shell
adrc --vim-plugin https://github.com/ervandew/supertab.git
```

or you can do the same just with Git:

```shell
git clone https://github.com/ervandew/supertab.git $ADRC/usr/vim/supertab
```

To see all helper commands, run `adrc --help`.

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
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so awesome, it should be illegal
 * [vim-gitgutter](https://github.com/airblade/vim-gitgutter): A Vim plugin which shows a git diff in the gutter (sign column) and stages/undoes hunks
 * [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors): True Sublime Text style multiple selections for Vim
 * [vim-repeat](https://github.com/tpope/vim-repeat): enable repeating supported plugin maps with "."
 * [vim-rooter](https://github.com/airblade/vim-rooter): Changes Vim working directory to project root (identified by presence of known directory or file)
 * [vim-sneak](https://github.com/justinmk/vim-sneak): The missing motion for Vim
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
