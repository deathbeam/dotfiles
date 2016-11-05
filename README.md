# awesome.rc
[![TravisCI Build Status](https://api.travis-ci.org/deathbeam/awesomedotrc.svg?branch=master)](https://travis-ci.org/deathbeam/awesomedotrc)

These are my configuration files for Linux and Mac. It is still work in progress, so expect a lot of changes, but I think it is stable enough to be usable. I put this README together, because I (like most of other programmers) do not have any life. I even added CI integration to this repo, because I was bored. Yes, you hear right, CI INTEGRATION TO FUCKING DOTFILES REPO. I doubt anyone will ever appreciate my effort, but [frankly, my dear, I don't give a damn](https://en.wikipedia.org/wiki/Frankly,_my_dear,_I_don't_give_a_damn). Expect a lot of changes in this repo, because most of the time I just cannot make up my mind, and I change my decisions very often.

## Requirements

* [python](https://www.python.org/downloads/) - Required for [dotbot](https://github.com/anishathalye/dotbot) to work properly. Python is installed by default on most Linux distributions and also on Mac.
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - Most of the installation process is managed via Git, so you need this one.

## Optional requirements

* bash - I am using bash, and my terminal configuration is working mostly for bash only. If you are using zsh, or fish or whatever, it's okay, I tried them all and eventually I came back to bash, mainly because some completion stuff I am using is a bit broken in other shells than bash. Otherwise, zsh is really great and if all this completion stuff was properly working there, I would be using zsh.
* [tmux](https://tmux.github.io/) - Terminal multiplexer. Awesome stuff, but I find myself to use it less and less, because I started using tiling window manager's features more. But still, tmux is really awesome, and have some great features what screen do not have. I have some really nice Tmux stuff in my repository, so feel free to try it, maybe you will like it.
* [vim](http://www.vim.org/download.php/) - Required for Vim stuff (of course). Needs to be installed with python support for all plugins to work correctly. If you are just starting with Vim, then I recommend you to run `vimtutor` from your CLI. Thank me later.
* [vifm](http://vifm.info/) - ncurses based file manager with vi like keybindings/modes/options/commands/configuration. I am still deciding between vifm and [ranger](http://nongnu.org/ranger/), but vifm have great name, so for now I am using it.
* [Firefox](https://www.mozilla.org/en-US/firefox/new/) - The only browser I found that can be properly styled to my likings (for example, doing what I did with my Firefox is with browsers like Chrome just not possible) and also allows me to watch porn in HD quality is Firefox. Just kidding, I don't watch porn. Also, has Vimperator. Install latest Firefox stable version, Vimperator do not works with Developer Edition.
* [vimperator](https://addons.mozilla.org/en-US/firefox/addon/vimperator/) - Vim for your firefox. It is really awesome, but if you prefer unmainained Pendactyl, then use it, or you want to have just Vi keybindings in your browser, but want to configure your browser through messsy JSON file or even worse, through setting menus (where you will need to use your mouse..) without possibility to store all these setting in nice dotfile repository, then use VimFX, you hipster. Otherwise, just use
  Vimperator, what is currently the best one (if you are not using Firefox Developer Edition, because Vimperator is totally broken there, and it do not seems that Vimperator devs are making any progress on fixing these issues).
* [Stylish](https://addons.mozilla.org/en-US/firefox/addon/stylish/) - Just cool extension that can style your browser. I do not found nice solution how to store my custom Firefox style in some dotfile, so this is last thing I do not like in this setup, you need to install my style manually from Addon menu (yes, I know, it is horrible, but it is only way that is currently working and styles entire top menu properly on my Mac OS).
* [editorconfig](https://github.com/editorconfig/editorconfig-core-c/blob/master/INSTALL.md) - For editorconfig plugin. This is not necessary at all, but EditorConfig is super awesome portable thing to configure indentation and whitespace settings for your project, and it works in most of editors, not only in Vim.

### macOS specific

* [kwm](https://github.com/koekeishiya/kwm) - Awesome tiling window manager for macOS. Noticed that I am using macOS instead of OSX? It is because Apple rebranded OSX to macOS in latest Sierra update. You can read more about it [here](https://techcrunch.com/2016/06/13/os-x-is-now-macos-and-gets-support-for-siri-auto-unlock-and-more/). Great stuff, right? Anyway, back to the point. Kwm is a lot better than Amethyst, if you are still using it. Are you asking why? Because it can be
  configured from dotfile, that is why. Also, it have nice focus borders, and is more similar to window managers on Linux, what I really miss on OSX, but I am not going to use XQuartz just to have i3 for my terminals here, lol.
* [khd](https://github.com/koekeishiya/khd) - Hotkey daemon for macOS, required to have keybindings in kwm. Originally these two was one project, but they got split, what is imo great thing.
* [iTerm2](http://iterm2.com/) - It is better than Terminal, and supports 256 colors, instead of Terminal's 16. Also, it have no titlebar mode, what is great. And my macOS setup is configured to be working properly with iTerm2.

## How to install?

It is simple, just use integrated dotbot installer

```shell
git clone https://github.com/deathbeam/awesomedotrc.git ~/.awesomedotrc && \
    ~/.awesomedotrc/install
```

I recommend to install [Hack](http://sourcefoundry.org/hack/) font. It is awesome for programming and runs in Vim really fast. I personally like DejaVu Sans Mono more, but it really slows down my Vim (for some unknown reason) so I am sticking to Hack. All my configurations tries to load Hack font if possible, otherwise they tries couple other good fonts and falls back to some common one if none is found.

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
 * [vim-submode](https://github.com/kana/vim-submode): Create your own submodes
 * [vim-surrond](https://github.com/tpope/vim-surround): quoting/parenthesizing made simple
 * [vim-unimpared](https://github.com/tpope/vim-unimpaired): pairs of handy bracket mappings
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
