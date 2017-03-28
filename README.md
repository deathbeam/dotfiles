# dotfiles
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/dotfiles.svg?branch=master)](https://travis-ci.org/deathbeam/dotfiles)

These are my configuration files for Linux and Mac. It is still work in progress, so expect a lot of changes, but I
think it is stable enough to be usable. I put this README together, because I (like most of other programmers) do not
have any life. I even added CI to this repo, because I was bored. Yes, you hear right, COUNTINUOS INTEGRATION TO
FUCKING DOTFILES REPO. I doubt anyone will ever appreciate my effort, but [frankly, my dear, I don't give a
damn](https://en.wikipedia.org/wiki/Frankly,_my_dear,_I_don't_give_a_damn). Expect a lot of changes in this repo,
because most of the time I just cannot make up my mind, and I change my decisions very often.

## Requirements

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - Most of the installation process is managed via
  Git, so you need this one.
* [stow](https://www.gnu.org/software/stow/) - Stow is used for dotfile installation (creating symlinks)

## How to install?

It is simple, just use `make`
```shell
git clone git://github.com/deathbeam/dotfiles ~/.dotfiles
cd ~/.dotfiles
make
```

Most of my dotfiles are using [Terminus](http://terminus-font.sourceforge.net/) font, so to make everything look
correct, install it in both TrueType and bitmap format.

## How to update?

You can just use Git:

```shell
cd ~/.dotfiles
git pull --rebase
make
```

## How to inlude your own stuff?

After you have installed dotfiles, you can start including your own stuff by creating appropriate `.local` dotfiles in
home directory:

```shell
$EDITOR ~/.gitconfig.local
$EDITOR ~/.vimrc.local
$EDITOR ~/.zshrc.local
$EDITOR ~/.tmux.conf.local
```

To add your own Vim, Tmux or Zsh plugin you can just clone it to proper `bundle` directory:

```shell
# Add SuperTab vim plugin
git clone git://github.com/ervandew/supertab ~/.vim/bundle/supertab

# Add Tmux sessionist plugin
git clone git://github.com/tmux-plugins/tmux-sessionist ~/.tmux/bundle/tmux-sessionist

# Add zsh-autoenv zsh plugin
git clone git://github.com/Tarrasch/zsh-autoenv ~/.zsh/bundle/zsh-autoenv
```

## Included stuff

### Shell
 * [alias-tips](https://github.com/djui/alias-tips): A plugin to help remembering those aliases you defined once
 * [base-16-shell](https://github.com/chriskempson/base16-shell): A shell script to change your shell's default ANSI colors but most importantly, colors 17 to 21 of your shell's 256 colorspace (if supported by your terminal)
 * [cdls](https://github.com/deathbeam/dotfiles/tree/experimental/zsh/.zsh/bundle/cdls): Runs `ls -A` on directory change
 * [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder written in Go
 * [k](https://github.com/supercrabtree/k): k is the new l, yo
 * [vi-mode](https://github.com/deathbeam/dotfiles/tree/experimental/zsh/.zsh/bundle/vi-mode): Enhanced Vi mode for zsh
   with history substring search support
 * [zim](https://github.com/Eriner/zim): ZIM - Zsh IMproved

### Vim
 * [base16-vim](https://github.com/chriskempson/base16-vim): Base16 for Vim
 * [comittia.vim](https://github.com/rhysd/committia.vim): A Vim plugin for more pleasant editing on commit messages
 * [deoplete.nvim](https://github.com/Shougo/deoplete.nvim): 🌠 Dark powered asynchronous completion framework for neovim
 * [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim): EditorConfig plugin for Vim
 * [fzf.vim](https://github.com/junegunn/fzf.vim): fzf :heart: vim
 * [syntastic](https://github.com/scrooloose/syntastic): Syntax checking hacks for vim
 * [tmux-complete.vim](https://github.com/wellle/tmux-complete.vim): Vim plugin for insert mode completion of words in
   adjacent tmux panes
 * [tsuquyomi](https://github.com/Quramy/tsuquyomi): A Vim plugin for TypeScript
 * [ultisnips](https://github.com/SirVer/ultisnips): The ultimate snippet solution for Vim
 * [vaxe](https://github.com/jdonaldson/vaxe): A modern, modular vim mode for Haxe.
 * [vim-commentary](https://github.com/tpope/vim-commentary): comment stuff out
 * [vim-dirvish](https://github.com/justinmk/vim-dirvish): Directory viewer for Vim ⚡️
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so awesome, it should be illegal
 * [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags): A Vim plugin that manages your tag files
 * [vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2): Updated javacomplete plugin for vim
 * [vim-logreview](https://github.com/andreshazard/vim-logreview): vim plugin for log navigation
 * [vim-obsession](https://github.com/tpope/vim-obsession): continuously updated session files
 * [vim-pathogen](https://github.com/tpope/vim-pathogen): Manage your runtimepath
 * [vim-polyglot](https://github.com/sheerun/vim-polyglot): A solid language pack for Vim.
 * [vim-repeat](https://github.com/tpope/vim-repeat): enable repeating supported plugin maps with "."
 * [vim-rooter](https://github.com/airblade/vim-rooter): Changes Vim working directory to project root (identified by presence of known directory or file)
 * [vim-snippets](https://github.com/honza/vim-snippets): contains snippets files for various programming languages
 * [vim-surround](https://github.com/tpope/vim-surround): quoting/parenthesizing made simple
 * [vim-test](https://github.com/janko-m/vim-test): Run your tests at the speed of thought
 * [vim-unimpaired](https://github.com/tpope/vim-unimpaired): pairs of handy bracket mappings
 * [vim-wiki](https://github.com/vimwiki/vimwiki): Personal Wiki for Vim
 * [yang.vim](https://github.com/nathanalderson/yang.vim): YANG syntax highlighting for VIM


### Tmux
 * [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum): Continuous saving of tmux environment. Automatic restore when tmux is started. Automatic tmux start when computer is turned on.
 * [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat): Enhances tmux search
 * [tmux-open](https://github.com/tmux-plugins/tmux-open): Tmux key bindings for quick opening of a highlighted file or url
 * [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect): Persists tmux environment across system restarts
 * [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible): basic tmux settings everyone can agree on
 * [tmux-yank](https://github.com/tmux-plugins/tmux-yank): Plugin for copying to system clipboard
 * [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator): Seamless navigation between tmux panes and vim splits
