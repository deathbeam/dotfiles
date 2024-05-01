# Adjust path to use various bin folders
export PATH="$PATH:$HOME/.local/bin:$HOME/.config/bin:$HOME/.cargo/bin:$HOME/.luarocks/bin/:$HOME/.npm-global/bin/:$HOME/.gem/ruby/2.6.0/bin/:$HOME/go/bin:$HOME/Apps/"

# Set go path to user home
export GOPATH="$HOME/go"

# Better pager
export PAGER="less -F -X"

# Set npm home to user home
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/default

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
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Use GPG agent for SSH
export SSH_AGENT_PID=""
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"

# Theme
export BASE16_THEME_DEFAULT="solarized-dark"
export BASE16_FZF_PATH=~/.zsh/pack/bundle/start/base16-fzf
export BASE16_POLYBAR_PATH=~/.config/polybar/base16-polybar/colors/base16-${BASE16_THEME_DEFAULT}.ini

# Auto scale for QT5 apps
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough
export QT_ENABLE_HIGHDPI_SCALING=1
export SCALE_FACTOR=1.5

[[ -f "$HOME/.profile.local" ]] && source "$HOME/.profile.local"

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi
