# Adjust path to use various bin folders
export PATH="$HOME/.local/bin:$HOME/.local/work/bin:$HOME/.nimble/bin:$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.3.0/bin/:$HOME/.gem/ruby/3.3.0/bin/:$HOME/.luarocks/bin/:$HOME/.npm-global/bin/:$HOME/.dotnet/tools:$HOME/Apps/:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# Set go path to user home
export GOPATH="$HOME/go"

# Set npm home to user home
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/default

# Preferred editor for local and remote sessions
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Better pager
export PAGER="less"
export MANPAGER="$EDITOR +Man!"

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Manually set your language environment
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Use GPG agent for SSH
export SSH_AGENT_PID=""
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"

# Theme
export BASE16_THEME_DEFAULT="solarized-dark"
export BASE16_FZF_PATH=~/.zsh/pack/bundle/start/base16-fzf

# Set the default terminal emulator
export TERMINAL="alacritty"

# Set path to wallpaper
export WALLPAPER="$HOME/.wallpaper"

# Fix Java window resizing in TWM
export _JAVA_AWT_WM_NONREPARENTING=1
export _MOTIF_WM_HINTS=1

# Set scaling
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_ENABLE_HIGHDPI_SCALING=1
export SCALE_FACTOR=1

[[ -f "$HOME/.profile.local" ]] && source "$HOME/.profile.local"

# Apply scale factor to all variables
function apply_scale_factor() {
    if [[ -z $SCALE_FACTOR ]]; then
        echo $1
        return
    fi

    local new_val=$(echo "$1 * $SCALE_FACTOR" | bc)
    new_val=${new_val%.*}
    echo $new_val
}

export DPI=$(apply_scale_factor 96)
export BAR_HEIGHT=$(apply_scale_factor 40)
export BAR_FONT_SIZE=$(apply_scale_factor 20)
export GDK_SCALE=$SCALE_FACTOR
export QT_SCALE_FACTOR=$SCALE_FACTOR
export WINIT_X11_SCALE_FACTOR=$SCALE_FACTOR
export STEAM_FORCE_DESKTOPUI_SCALING=$SCALE_FACTOR
