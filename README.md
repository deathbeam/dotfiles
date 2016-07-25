# awesomedotrc

This is my Vim, ZSH and Prezto configuration. It is still work in progress, so expect a lot of changes, but I think it is stable enough to be usable.

![Vim](/screenshots/vim.png?raw=true "Vim")

![Terminal](/screenshots/terminal.png?raw=true "Terminal")

## Requirements

* zsh - This is ZSH and Vim config anyway, duh
* vim - Same as above
* git - Needed to setup Pretzo and z.sh, and also for Vim Plug
* python - Needed for some Vim plugins
* cowsay - Just for fancy MOTD (the most important thing in this entire setup, of course)

## How to install?

I made small automated installation script, what will update your `.zshrc`, `.zshpreztorc` and `.vimrc` and make NeoVim to use same configuration and plugins as Vim.

```shell
git clone https://github.com/deathbeam/awesomedotrc.git ~/.awesomedotrc
sh ~/.awesomedotrc/install
```

I recommend to install [Hack for Powerline](https://github.com/powerline/fonts/tree/master/Hack) font. It is awesome for programming and also supports special symbols used in ZSH theme we are using here and Vim config is also configured to try to use it when available.

Also, it is preferred to use [Tomorrow Night](https://github.com/chriskempson/tomorrow-theme) color scheme for your favorite terminal. It will look a lot better, because Vim is also using this color scheme.

## How to update?

There is nothing simplier, just use git :)

```shell
git -C ~/.awesomedotrc pull --rebase && zsh
```

## How to inlude your own stuff?

After you have installed awesomedotrc, you can create `user` directory and start including your own stuff:

```shell
mkdir `~/.awesomedotrc/user && cd  ~/.awesomedotrc/user
```

Here, you can create:
 * `zshrc` - Custom ZSH configuration
 * `zpreztorc` - Custom Prezto configuration
 * `vimrc` - Custom VIM configuration

## Included stuff

### VIM
 * [NERD Tree](https://github.com/scrooloose/nerdtree): A tree explorer plugin for vim
 * [snipMate.vim](https://github.com/garbas/vim-snipmate): snipMate.vim aims to be a concise vim script that implements some of TextMate's snippets features in Vim
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so awesome, it should be illegal
 * [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim): Fuzzy file, buffer, mru and tag finder
 * [syntastic](https://github.com/scrooloose/syntastic): Syntax checking hacks for vim
 * [ack.vim](https://github.com/mileszs/ack.vim): Vim plugin for the Perl module / CLI script 'ack'
