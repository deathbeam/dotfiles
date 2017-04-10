# dotfiles
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/dotfiles.svg?branch=master)](https://travis-ci.org/deathbeam/dotfiles)

These are my configuration files for Linux and Mac. It is still work in
progress, so expect a lot of changes, but I think it is stable enough to be
usable.
My Vim configuration is great for Java, Haxe and Typescript development when
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
      ~/.vim/bundle/local/supertab

    # Add Tmux sessionist plugin
    git clone git://github.com/tmux-plugins/tmux-sessionist \
      ~/.tmux/bundle/local/tmux-sessionist

    # Add zsh-autoenv zsh plugin
    git clone git://github.com/Tarrasch/zsh-autoenv \
      ~/.zsh/bundle/local/zsh-autoenv

## Included stuff

### ZSH
 * [alias-tips](https://github.com/djui/alias-tips): A plugin to help
   remembering those aliases you defined once
 * [base-16-shell](https://github.com/chriskempson/base16-shell): A shell script
   to change your shell's default ANSI colors but most importantly, colors 17 to
   21 of your shell's 256 colorspace (if supported by your terminal)
 * [__cdls__*](https://github.com/deathbeam/dotfiles/tree/master/zsh/.zsh/bundle/cdls.plugin.zsh):
   Runs `ls -A` on directory change
 * [__codi__*](https://github.com/deathbeam/dotfiles/tree/master/zsh/.zsh/bundle/codi.plugin.zsh):
   A nice way to use Codi is through a shell wrapper
 * [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder written
   in Go
 * [__globalias__**](https://github.com/deathbeam/dotfiles/tree/master/zsh/.zsh/bundle/globalias.plugin.zsh):
   Expands all glob expressions, subcommands and aliases (including global)
 * [__ix__*](https://github.com/deathbeam/dotfiles/tree/master/zsh/.zsh/bundle/ix.plugin.zsh):
   A command line pastebin - shell
 * [__vi-mode__**](https://github.com/deathbeam/dotfiles/tree/master/zsh/.zsh/bundle/vi-mode.plugin.zsh):
   Enhanced Vi mode for zsh with history substring search support
 * [zim](https://github.com/Eriner/zim): ZIM - Zsh IMproved

### Vim
 * [base16-vim](https://github.com/chriskempson/base16-vim): Base16 for Vim
 * [codi.vim](https://github.com/metakirby5/codi.vim):
   :notebook_with_decorative_cover: The interactive scratchpad for hackers.
 * [comittia.vim](https://github.com/rhysd/committia.vim): A Vim plugin for more
   pleasant editing on commit messages
 * [completor.vim](https://github.com/maralla/completor.vim): Async completion
   framework made ease
 * [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim):
   EditorConfig plugin for Vim
 * [fzf.vim](https://github.com/junegunn/fzf.vim): fzf :heart: vim
 * [__fzf-contrib__*](https://github.com/deathbeam/dotfiles/tree/master/vim/.vim/bundle/fzf-contrib):
   Completion menu using FZF, tab-completion, support for `ripgrep` in FZF
 * [syntastic](https://github.com/scrooloose/syntastic): Syntax checking hacks
   for vim
 * [tsuquyomi](https://github.com/Quramy/tsuquyomi): A Vim plugin for TypeScript
 * [ultisnips](https://github.com/SirVer/ultisnips): The ultimate snippet
   solution for Vim
 * [vaxe](https://github.com/jdonaldson/vaxe): A modern, modular vim mode for
   Haxe.
 * [vim-commentary](https://github.com/tpope/vim-commentary): comment stuff out
 * [vim-dirvish](https://github.com/justinmk/vim-dirvish): Directory viewer for
   Vim ⚡️
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so
   awesome, it should be illegal
 * [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags): A Vim
   plugin that manages your tag files
 * [vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2):
   Updated javacomplete plugin for vim
 * [vim-logreview](https://github.com/andreshazard/vim-logreview): vim plugin
   for log navigation
 * [vim-obsession](https://github.com/tpope/vim-obsession): continuously updated
   session files
 * [vim-pathogen](https://github.com/tpope/vim-pathogen): Manage your
   runtimepath
 * [vim-polyglot](https://github.com/sheerun/vim-polyglot): A solid language
   pack for Vim.
 * [vim-repeat](https://github.com/tpope/vim-repeat): enable repeating supported
   plugin maps with "."
 * [vim-rooter](https://github.com/airblade/vim-rooter): Changes Vim working
   directory to project root (identified by presence of known directory or file)
 * [vim-snippets](https://github.com/honza/vim-snippets): contains snippets
   files for various programming languages
 * [vim-surround](https://github.com/tpope/vim-surround): quoting/parenthesizing
   made simple
 * [vim-test](https://github.com/janko-m/vim-test): Run your tests at the speed
   of thought
 * [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator):
   Seamless navigation between tmux panes and vim splits
 * [vim-unimpaired](https://github.com/tpope/vim-unimpaired): pairs of handy
   bracket mappings
 * [vim-wiki](https://github.com/vimwiki/vimwiki): Personal Wiki for Vim
 * [yang.vim](https://github.com/nathanalderson/yang.vim): YANG syntax
   highlighting for VIM


### Tmux
 * [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum): Continuous
   saving of tmux environment. Automatic restore when tmux is started. Automatic
   tmux start when computer is turned on.
 * [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat): Enhances tmux
   search
 * [tmux-open](https://github.com/tmux-plugins/tmux-open): Tmux key bindings for
   quick opening of a highlighted file or url
 * [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect): Persists
   tmux environment across system restarts
 * [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible): basic tmux
   settings everyone can agree on
 * [tmux-yank](https://github.com/tmux-plugins/tmux-yank): Plugin for copying to
   system clipboard
 * [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator):
   Seamless navigation between tmux panes and vim splits

__*__ _These plugins are made by me, so do not bother searching for them online_  
__**__ _These plugins are copied from oh-my-zsh, with some modifications_
