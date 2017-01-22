# dotfiles
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/dotfiles.svg?branch=master)](https://travis-ci.org/deathbeam/dotfiles)

These are my configuration files for Linux and Mac. It is still work in progress, so expect a lot of changes, but I
think it is stable enough to be usable. I put this README together, because I (like most of other programmers) do not
have any life. I even added CI to this repo, because I was bored. Yes, you hear right, COUNTINUOS INTEGRATION TO
FUCKING DOTFILES REPO. I doubt anyone will ever appreciate my effort, but [frankly, my dear, I don't give a
damn](https://en.wikipedia.org/wiki/Frankly,_my_dear,_I_don't_give_a_damn). Expect a lot of changes in this repo,
because most of the time I just cannot make up my mind, and I change my decisions very often.

## Requirements

* [python](https://www.python.org/downloads/) - Required for [dotbot](https://github.com/anishathalye/dotbot) to work
  properly. Python is installed by default on most Linux distributions and also on Mac.
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - Most of the installation process is managed via
  Git, so you need this one.

## Optional requirements

* zsh - Zsh is awesome. I was using bash, but then switched to zsh, and it is pretty much compatible with all bash stuff
  and it is also faster and nicer.
* [tmux](https://tmux.github.io/) - Terminal multiplexer. Awesome stuff, but I find myself to use it less and less,
  because I started using tiling window manager's features more. But still, tmux is really awesome, and have some great
  features what screen do not have. I have some really nice Tmux stuff in my repository, so feel free to try it, maybe
  you will like it.
* [vim](http://www.vim.org/download.php/) - Required for Vim stuff (of course). Needs to be installed with python
  support for all plugins to work correctly. If you are just starting with Vim, then I recommend you to run `vimtutor`
  from your CLI. Thank me later.
* [Firefox](https://www.mozilla.org/en-US/firefox/new/) - The only browser I found that can be properly styled to my
  likings (for example, doing what I did with my Firefox is with browsers like Chrome just not possible)
* [vimfx](https://addons.mozilla.org/en-US/firefox/addon/vimfx/) - Vim for your firefox. No need to say more.
* [Stylish](https://addons.mozilla.org/en-US/firefox/addon/stylish/) - Just cool extension that can style your browser.
  I do not found nice solution how to store my custom Firefox style in some dotfile, so this is last thing I do not like
  in this setup, you need to install my style manually from Addon menu (yes, I know, it is horrible, but it is only way
  that is currently working and styles entire top menu properly on my Mac OS).
* [editorconfig](https://github.com/editorconfig/editorconfig-core-c/blob/master/INSTALL.md) - For editorconfig plugin.
  This is not necessary at all, but EditorConfig is super awesome portable thing to configure indentation and whitespace
  settings for your project, and it works in most of editors, not only in Vim.

### macOS specific

* [kwm](https://github.com/koekeishiya/kwm) - Awesome tiling window manager for macOS. Noticed that I am using macOS
  instead of OSX? It is because Apple rebranded OSX to macOS in latest Sierra update. You can read more about it
  [here](https://techcrunch.com/2016/06/13/os-x-is-now-macos-and-gets-support-for-siri-auto-unlock-and-more/). Great
  stuff, right? Anyway, back to the point. Kwm is a lot better than Amethyst, if you are still using it. Are you asking
  why? Because it can be configured from dotfile, that is why. Also, it have nice focus borders, and is more similar to
  window managers on
  Linux, what I really miss on OSX, but I am not going to use XQuartz just to have i3 for my terminals here, lol.
* [khd](https://github.com/koekeishiya/khd) - Hotkey daemon for macOS, required to have keybindings in kwm. Originally
  these two was one project, but they got split, what is imo great thing.
* [karabiner-elements](https://github.com/tekezo/Karabiner-Elements) - Can remap our Caps-Lock key to Hyper key, what I
  am using in khd config as mod key for everything. You will need specifically [this
  build](https://cl.ly/hwJn/download/Karabiner-Elements-0.90.61.dmg) what have support for hyper key remapping. Rest of
  configuration that will remap caps lock to hyper is in dotfiles.
* [Alfred 3](https://www.alfredapp.com/) - Used as launcher application in my kwm/khd config. Not needed, you can just
  adjust keybindings in khdrc to use Spotlight, but Alfred is just too awesome to pass.
* [iTerm2](http://iterm2.com/) - It is better than Terminal, and supports 256 colors, instead of Terminal's 16. Also, it
  have no titlebar mode, what is great. And my macOS setup is configured to be working properly with iTerm2.

## How to install?

It is simple, just use integrated dotbot installer

```shell
git clone https://github.com/deathbeam/dotfiles.git ~/.dotfiles && \
    ~/.dotfiles/install
```

These dotfiles are configured with [Terminus](http://terminus-font.sourceforge.net/) font in mind, so better install it.
To install Firefox theme, use [Stylish](https://addons.mozilla.org/en-US/firefox/addon/stylish/) and enter this URL to
`Install from URLs`:

```
https://raw.githubusercontent.com/deathbeam/dotfiles/master/lib/firefox/firefox.css
```

## How to update?

You can use

```
dottool --update
```

what was made exactly for this. It will fetch latest changes from remote, then runs rebase and at end run installation
script to update links and installed stuff. Or, if you want, you can use Git like this:


```shell
git -C $DOTHOME pull --rebase
```

## How to inlude your own stuff?

After you have installed dotfiles, you can start including your own stuff by using the `dottool --open` command:

```shell
dottool --open bashrc
dottool --open vimrc
dottool --open tmux.conf
dottool --open gitconfig
```

or manually without helper:

```shell
vim $DOTHOME/usr/bashrc
vim $DOTHOME/usr/vimrc
vim $DOTHOME/usr/tmux.conf
vim $DOTHOME/usr/gitconfig
```

To add your own Vim plugin you can use `dottool --vim-plugin` command. For example to add
[SuperTab](https://github.com/ervandew/supertab), all you need to do is run this command:

```shell
dottool --vim-plugin https://github.com/ervandew/supertab.git
```

or you can do the same just with Git:

```shell
git clone https://github.com/ervandew/supertab.git $DOTHOME/usr/vim/supertab
```

To see all helper commands, run `dottool --help`.

## Included stuff

### Shell
 * [zim](https://github.com/Eriner/zim): ZIM - Zsh IMproved
 * [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder written in Go
 * [base-16-shell](https://github.com/chriskempson/base16-shell): A shell script to change your shell's default ANSI colors but most importantly, colors 17 to 21 of your shell's 256 colorspace (if supported by your terminal)

### Vim
 * [base16-vim](https://github.com/chriskempson/base16-vim): Base16 for Vim
 * [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim): EditorConfig plugin for Vim
 * [fzf.vim](https://github.com/junegunn/fzf.vim): fzf :heart: vim
 * [pathogen.vim](https://github.com/tpope/vim-pathogen): Manage your runtimepath
 * [supertab](https://github.com/ervandew/supertab): Perform all your vim insert mode completions with Tab
 * [syntastic](https://github.com/scrooloose/syntastic): Syntax checking hacks for vim
 * [ultisnips](https://github.com/SirVer/ultisnips): The ultimate snippet solution for Vim
 * [vim-commentary](https://github.com/tpope/vim-commentary): comment stuff out
 * [vim-fugitive](https://github.com/tpope/vim-fugitive): A Git wrapper so awesome, it should be illegal
 * [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags): A Vim plugin that manages your tag files
 * [vim-obsession](https://github.com/tpope/vim-obsession): continuously updated session files
 * [vim-repeat](https://github.com/tpope/vim-repeat): enable repeating supported plugin maps with "."
 * [vim-rooter](https://github.com/airblade/vim-rooter): Changes Vim working directory to project root (identified by presence of known directory or file)
 * [vim-snippets](https://github.com/honza/vim-snippets): contains snippets files for various programming languages
 * [vim-surround](https://github.com/tpope/vim-surround): quoting/parenthesizing made simple
 * [vim-unimpaired](https://github.com/tpope/vim-unimpaired): pairs of handy bracket mappings
 * [vim-vinegar](https://github.com/tpope/vim-vinegar): combine with netrw to create a delicious salad dressing
 * [vim-wiki](https://github.com/vimwiki/vimwiki): Personal Wiki for Vim

### Tmux
 * [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum): Continuous saving of tmux environment. Automatic restore when tmux is started. Automatic tmux start when computer is turned on.
 * [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat): Enhances tmux search
 * [tmux-open](https://github.com/tmux-plugins/tmux-open): Tmux key bindings for quick opening of a highlighted file or url
 * [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect): Persists tmux environment across system restarts
 * [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible): basic tmux settings everyone can agree on
 * [tmux-yank](https://github.com/tmux-plugins/tmux-yank): Plugin for copying to system clipboard
 * [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator): Seamless navigation between tmux panes and vim splits

## Thanks to..

 * [skwp/dotfiles](https://github.com/skwp/dotfiles) for some sane .gitignore config for ignoring Vim and ctags stuff
 * [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) for sane .gitconfig and some things in
   .gitignore, and also for enabling Bash 4 features for tab completion if possible
 * [amix/vimrc](https://github.com/amix/vimrc) for a lot of stuff in my vimrc. Without configurations, what are really
   nicely explained in that repo, I would be lost like forever
 * [twily](http://twily.info/) for his awesome Firefox stylish theme, what I configured to suit my needs
 * [nerdbar.widget](https://github.com/herrbischoff/nerdbar.widget) for awesome widget for Ubersicht on what I based on
   mine
 * [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles) for some parts of tmux configuration. I also want to
   mention that I absolutely love their youtube channel
 * I also found some things in other dotfile repositories (for example most of the great config in vimperatorrc), but I
   totally lost track, so sorry if I forgot to mention anyone here
