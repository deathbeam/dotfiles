# vim:foldmethod=marker:set ft=sh:

# Set pyenv home
export PYENV_ROOT="$HOME/.pyenv"

# Adjust path to use various bin folders
export PATH="$PYENV_ROOT/bin:$PATH:$HOME/.local/bin:$HOME/.config/bin:$HOME/.cargo/bin:$HOME/.luarocks/bin/:$HOME/.npm-global/bin/:$HOME/.gem/ruby/2.5.0/bin/:$HOME/go/bin:/usr/local/osx-ndk-x86/bin"

# Set go path to user home
export GOPATH="$HOME/go"

# Set npm home to user home
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Set zim home to user home
export ZIM_HOME="$HOME/.zim"

# Fix Java window resizing in TWM
export _JAVA_AWT_WM_NONREPARENTING=1
export _MOTIF_WM_HINTS=1

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Manually set your language environment
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Preferred editor for local and remote sessions
export EDITOR="vim"
export VISUAL="$EDITOR"

# Auto scale for QT5 apps
export QT_AUTO_SCREEN_SCALE_FACTOR=1

[[ -f "$HOME/.profile.local" ]] && source "$HOME/.profile.local"
