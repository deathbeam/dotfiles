# General {{{

# Source .profile
if [ -f ~/.profile ]; then
  source ~/.profile
fi

# History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zhistory"
HISTSIZE=100000
SAVEHIST=50000
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Input configuration
setopt EMACS
setopt INTERACTIVE_COMMENTS
setopt GLOB_DOTS
setopt EXTENDED_GLOB
WORDCHARS=${WORDCHARS//[\/]}

# Directory configuration
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CD_SILENT
setopt PUSHD_IGNORE_DUPS

# Job configuration
setopt LONG_LIST_JOBS
setopt NO_BG_NICE
setopt NO_CHECK_JOBS
setopt NO_HUP

# GPG configuration
# export GPG_TTY=$(tty)

# Set terminal title to current directory
precmd() { print -Pn "\e]2;${PWD}\a" }

# }}}

# Mappings {{{

autoload -z edit-command-line
zle -N edit-command-line
bindkey '^[' edit-command-line

# }}}

# Aliases & functions {{{

# Alias nvim
if command -v nvim >/dev/null 2>&1; then
  alias vim=nvim
  alias vimdiff='nvim -d'
  alias nvimf='nvim -c "FzfLua files"'
  alias nviml='nvim --listen /tmp/nvim.pipe'
  alias vimf='nvimf'
  alias viml='nviml'
fi

# Alias copy/paste
function vcopy {
  if command -v wl-copy >/dev/null 2>&1 && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    wl-copy
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  fi
}
function vpaste {
  if command -v wl-paste >/dev/null 2>&1 && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    wl-paste
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --output
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -o
  fi
}

# Why is this running
alias why='witr'

# Arch aliases
# Show unnecessary packages
alias pan='yay -Qqd | yay -Rsu --print -'
# Upadte mirrors
alias pam='rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist'
# Remove orphaned packages
alias pac='yay -Rns $(yay -Qtdq)'
# Update system
alias pau='yay -Syu'
alias pauu='yay -Syu --noconfirm'
# Remove package
alias par='yay -Rnsu'
alias parr='yay -Rnsu --noconfirm'
# Install package
alias pai='yay -Sy'
alias paii='yay -Sy --noconfirm'

# Set proxy
function setproxy {
  export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

  local reversed_proxy=$(echo $1 | rev)
  local host=$(echo $reversed_proxy | cut -d: -f2- | rev)
  local port=$(echo $reversed_proxy | cut -d: -f1 | rev)

  if [ -n "$2" ] && [ -n "$3" ]; then
    local user=$2
    local password=$3
    export http_proxy="http://$user:$password@$1"
    export JDK_JAVA_OPTIONS="-Dhttp.proxyHost='$host' -Dhttp.proxyPort='$port' -Dhttps.proxyHost='$host' -Dhttps.proxyPort='$port' -Dhttp.nonProxyHosts='$no_proxy' -Dhttp.proxyUser='$user' -Dhttp.proxyPassword='$password' -Dhttps.proxyUser='$user' -Dhttps.proxyPassword='$password'"
  else
    export http_proxy="http://$1"
    export JDK_JAVA_OPTIONS="-Dhttp.proxyHost='$host' -Dhttp.proxyPort='$port' -Dhttps.proxyHost='$host' -Dhttps.proxyPort='$port' -Dhttp.nonProxyHosts='$no_proxy'"
  fi

  export https_proxy=$http_proxy
  export ftp_proxy=$http_proxy
  export rsync_proxy=$http_proxy
  export HTTP_PROXY=$http_proxy
  export HTTPS_PROXY=$http_proxy
  export FTP_PROXY=$http_proxy
  export RSYNC_PROXY=$http_proxy
  export NO_PROXY=localhost,127.0.0.1
}

# Unset proxy
function unsetproxy {
  unset http_proxy https_proxy ftp_proxy rsync_proxy \
    HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY \
    JDK_JAVA_OPTIONS
}

# }}}

# Plugins {{{

# Set git alias prefix
zstyle ':zim:git' aliases-prefix g

# Enable colors for ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Configure autocomplete
zstyle ':autocomplete:*' delay 0.5

# Pathogen-like loader for plugins
if [ -z "$PLUGINS_LOADED" ]; then
  PLUGINS_LOADED=()
  for filename in ~/.zsh/pack/*/start/**/*(.N); do
    case "$filename" in
      (*.plugin.zsh|*init.zsh|*.zsh-theme)
        plugindir="${filename:h}"
        functiondir="$plugindir/functions"
        if [ -d "$functiondir" ]; then
          fpath=( "$functiondir" "${fpath[@]}" )
          for pluginfunction in $functiondir/*(.N); do
            functionname="${pluginfunction:t}"
            autoload -Uz $functionname
          done
        fi
        source "$filename" >/dev/null 2>&1
        PLUGINS_LOADED+=("$filename")
        ;;
    esac
  done
  export PLUGINS_LOADED
fi

# Bind c-n and c-p to navigate in completion menu properly
bindkey -M menuselect '^N' menu-complete
bindkey -M menuselect '^P' reverse-menu-complete

# Bind shift-tab to accept autosuggestions
bindkey '^[[Z' autosuggest-accept

# Configure prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Initialize mise if installed
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Configure FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--no-hscroll --color=border:#268bd2 --border=none --margin 0,0 --preview-window=border-sharp:wrap --no-separator --info=inline-right"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='rg --files --hidden --follow --null | xargs -0 dirname | uniq'

# Adjust git aliases
unalias gh 2>/dev/null # Conflict with github-cli
unalias gdu 2>/dev/null # Conflict with gdu
alias gc='git commit --signoff --verbose'
alias gca='git commit --signoff --verbose --all'
alias gcA='git commit --signoff --verbose --patch'
alias gcm='git commit --signoff --message'

# Set theme last
source ~/.zsh/pack/bundle/start/tinted-shell/scripts/base16-$BASE16_THEME_DEFAULT.sh;
source ~/.zsh/pack/bundle/start/tinted-fzf/sh/base16-$BASE16_THEME_DEFAULT.sh;
export BAT_THEME="base16-256"

# }}}

# User configuration {{{

# Load user config
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -f "$HOME/.zshrc.work" ] && source "$HOME/.zshrc.work"

# }}}
