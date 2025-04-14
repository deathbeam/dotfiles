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
export GPG_TTY=$(tty)

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

  reversed_proxy=$(echo $1 | rev)
  host=$(echo $reversed_proxy | cut -d: -f2- | rev)
  port=$(echo $reversed_proxy | cut -d: -f1 | rev)

  if [ -n "$2" ] && [ -n "$3" ]; then
    user=$2
    password=$3
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

# Enable recent directories and files completion
function recent_files() {
  fasd_out=$(fasd -flR)
  nvim_out=$(nvim --headless -u NONE -c"echo v:oldfiles | qall" 2>&1 | sed "s/[,'[]//g" | sed "s/]//g" | tr " " "\n")
  echo $fasd_out $nvim_out | tr " " "\n" | uniq
}
+autocomplete:recent-directories() {
  reply=(${(f)"$(fasd -dlR)"})
}
+autocomplete:recent-files() {
  reply=(${(f)"$(recent_files)"})
}

# Pathogen-like loader for plugins
if [ -z "$PLUGINS_LOADED" ]; then
  PLUGINS_LOADED=()
  while read filename; do
    plugindir="$(dirname $filename)"
    functiondir="$plugindir/functions"
    if [ -d "$functiondir" ]; then
      fpath=( "$functiondir" "${fpath[@]}" )
      for pluginfunction in $functiondir/*(.); do
        functionname="$(basename $pluginfunction)"
        autoload -Uz $functionname
      done
    fi
    source "$filename" >/dev/null 2>&1
    PLUGINS_LOADED+=("$filename")
  done <<< $(find -L ~/.zsh/pack/*/start -type f \( -name "*.zsh-theme" -or -name "*.plugin.zsh" -or -name "init.zsh" \) | sort)
  export PLUGINS_LOADED
fi

# Bind c-n and c-p to navigate in completion menu properly
bindkey -M menuselect '^N' menu-complete
bindkey -M menuselect '^P' reverse-menu-complete

# Bind shift-tab to accept autosuggestions
bindkey '^[[Z' autosuggest-accept

# Load fzf after plugins to be able to override them
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--no-hscroll --color=border:#268bd2 --border=none --margin 0,0 --preview-window=border-sharp:wrap --no-separator --info=inline-right --bind 'ctrl-e:execute(echo {+} | xargs -o nvim)'"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='rg --files --hidden --follow --null | xargs -0 dirname | uniq'

# Adjust git aliases
unalias gh 2>/dev/null # Conflict with github-cli
alias gc='git commit --signoff --verbose'
alias gca='git commit --signoff --verbose --all'
alias gcA='git commit --signoff --verbose --patch'
alias gcm='git commit --signoff --message'

# Set virtualenv shared requirements txt
export AUTOSWITCH_DEFAULT_REQUIREMENTS="$HOME/.requirements.txt"

# Set theme last
function () {
    local theme=$1
    local current_theme
    zstyle -g current_theme ':plugin:fast-syntax-highlighting' theme
    if [[ $current_theme != $theme ]]; then
        fast-theme $theme
    fi
} base16
set_theme $BASE16_THEME_DEFAULT true
export BAT_THEME="base16-256"

# Load asdf
if [ -d /opt/asdf-vm ]; then
  . /opt/asdf-vm/asdf.sh
fi

# }}}

# User configuration {{{

# Load user config
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -f "$HOME/.zshrc.work" ] && source "$HOME/.zshrc.work"

# }}}
