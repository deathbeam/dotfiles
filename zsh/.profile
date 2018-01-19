# vim:foldmethod=marker:set ft=sh:

# Adjust path to use various bin folders
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.luarocks/bin/:$HOME/.npm-global/bin/:$HOME/.gem/ruby/2.4.0/bin/"

# Set npm home to user home
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Fix Java window resizing in TWM
export _JAVA_AWT_WM_NONREPARENTING=1

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

[[ -f "$HOME/.profile.local" ]] && source "$HOME/.profile.local"
