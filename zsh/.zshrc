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
fi

# Alias xclip copy/paste
if command -v xclip >/dev/null 2>&1; then
  alias xcopy='xclip -i -selection clipboard'
  alias xpaste='xclip -o -selection clipboard'
elif command -v xsel >/dev/null 2>&1; then
  alias xcopy='xsel --clipboard --input'
  alias xpaste='xsel --clipboard --output'
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
}

# Unset proxy
function unsetproxy {
  unset http_proxy https_proxy ftp_proxy rsync_proxy \
    HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY
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

# Pacman
zstyle ':zim:pacman' frontend 'yay'
zstyle ':zim:pacman' helpers 'yay'

# Set git alias prefix
zstyle ':zim:git' aliases-prefix g

# Autocomplete
zstyle ':autocomplete:*' insert-unambiguous yes
zstyle ':autocomplete:*' add-space executables aliases functions builtins reserved-words commands
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

# improved tab completion with autocompletion
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
autoload -Uz cdr

# set base16 thee for syntax highlighting
function () {
    local theme=$1
    local current_theme
    zstyle -g current_theme ':plugin:fast-syntax-highlighting' theme
    if [[ $current_theme != $theme ]]; then
        fast-theme $theme
    fi
} base16

# Adjust git aliases
unalias gh 2>/dev/null
alias gc='git commit --signoff --verbose'
alias gca='git commit --signoff --verbose --all'
alias gcA='git commit --signoff --verbose --patch'
alias gcm='git commit --signoff --message'

# Load fzf after plugins to be able to override them
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use faster FZF grep command if possible
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
  export FZF_ALT_C_COMMAND='rg --files --hidden --follow --glob "!.git/*" --null | xargs -0 dirname | uniq'
elif command -v ag >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='ag -g ""'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
fi

# Load base16 theme
set_theme $BASE16_THEME true

# }}}

# User configuration {{{

# Load user config
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# }}}
