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

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

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

# Set the string below to the desired terminal title format string.
# Below uses the following format: 'username@host:/current/directory'
zstyle ':zim:termtitle' format '%n@%m:%~'

# Set git alias prefix
zstyle ':zim:git' aliases-prefix g

# This determines what highlighters will be used with the syntax-highlighting module.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

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

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle -d ':completion:*' format
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1a --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# remove prefix
zstyle ':fzf-tab:*' prefix ''
# search hidden by default
_comp_options+=(globdots)

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
base16_solarized-dark true
. ~/.zsh/pack/bundle/start/base16-fzf/bash/base16-solarized-dark.config

# }}}

# User configuration {{{

# Load user config
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# }}}
