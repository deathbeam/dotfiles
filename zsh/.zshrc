# vim:foldmethod=marker:set ft=zsh:

# General {{{

# Source .profile
if [ -f ~/.profile ]; then
  source ~/.profile
fi

# Enable colors
export CLICOLOR=1

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Emacs command mode (its better than vi sadly)
setopt emacs

# Expand dots
setopt globdots

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# }}}

# Aliases & functions {{{

# Alias nvim
if command -v nvim >/dev/null 2>&1; then
  alias vim=nvim
  alias vimdiff='nvim -d'
fi

# Alias copy/paste
if command -v xsel >/dev/null 2>&1; then
  alias c='xsel --clipboard --input'
  alias p='xsel --clipboard --output'
fi

# Set proxy
function setproxy {
  export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
  export http_proxy=http://$1
  export https_proxy=$http_proxy
  export ftp_proxy=$http_proxy
  export rsync_proxy=$http_proxy
  export HTTP_PROXY=$http_proxy
  export HTTPS_PROXY=$http_proxy
  export FTP_PROXY=$http_proxy
  export RSYNC_PROXY=$http_proxy
  parts=(${(s/:/)1})
  host=${parts[1]}
  port=${parts[2]}
  export JDK_JAVA_OPTIONS="-Dhttp.proxyHost=$host -Dhttp.proxyPort=$port -Dhttps.proxyHost=$host -Dhttps.proxyPort=$port"
}

# Unset proxy
function unsetproxy {
  unset http_proxy https_proxy ftp_proxy rsync_proxy \
    HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY \
    JDK_JAVA_OPTIONS
}

# Arch utilities
function arch-update-mirrors {
  rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist
}

function arch-remove-orphans {
  yay -Rns $(yay -Qtdq)
}

function arch-update {
  yay -Syu
}

# }}}

# Plugins {{{

# Expand dots
zstyle ':zim:input' double-dot-expand yes

# Set git alias prefix
zstyle ':zim:git' aliases-prefix g

# Autocomplete
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

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

# Completion bindings
bindkey -M menuselect '^N' menu-complete
bindkey -M menuselect '^P' reverse-menu-complete
autoload -Uz cdr
() {
   local -a prefix=( '\e'{\[,O} )
   local -a up=( ${^prefix}A ) down=( ${^prefix}B )
   local key=
   for key in $up[@]; do
      bindkey "$key" up-line-or-history
   done
   for key in $down[@]; do
      bindkey "$key" down-line-or-history
   done
}

# Adjust git aliases
unalias gh 2>/dev/null
alias gc='git commit --signoff --verbose'
alias gca='git commit --signoff --verbose --all'
alias gcA='git commit --signoff --verbose --patch'
alias gcm='git commit --signoff --message'

# Load fzf after plugins to be able to override them
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--bind tab:down --bind btab:up --color=border:#268bd2 --border=sharp --margin 0,0 --preview-window=border-sharp"

# Use faster FZF grep command if possible
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
  export FZF_ALT_C_COMMAND='rg --files --hidden --follow --glob "!.git/*" --null | xargs -0 dirname | uniq'
elif command -v ag >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='ag -g ""'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
fi

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

# }}}

# User configuration {{{

# Load user config
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# }}}
