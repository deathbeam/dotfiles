# vim:foldmethod=marker:set ft=zsh:

# General {{{

# Source .profile
if [ -f ~/.profile ]; then
  source ~/.profile
fi

# Enable colors
export CLICOLOR=1

# }}}

# Aliases & functions {{{

# Alias xclip copy/paste
if command -v xclip >/dev/null 2>&1; then
  alias xcopy='xclip -i -selection clipboard'
  alias xpaste='xclip -o -selection clipboard'
fi

# Open Vim and start saving it's session
alias vims='vim -c "Session"'

# }}}

# Plugins {{{

# Load zim
if [ -f ~/.zim/init.zsh ]; then
  # Select what modules you would like enabled.
  zmodules=( \
    archive \
    directory \
    environment \
    fasd \
    git \
    git-info \
    history \
    input \
    utility \
    prompt \
    syntax-highlighting \
    history-substring-search \
    completion)

  # Set the string below to the desired terminal title format string.
  # Below uses the following format: 'username@host:/current/directory'
  ztermtitle='%n@%m:%~'

  # This determines what highlighters will be used with the syntax-highlighting module.
  zhighlighters=(main brackets cursor)

  # Set prompt theme
  zprompt_theme='pure'
  PURE_PROMPT_SYMBOL='$'

  # Source zim
  source ~/.zim/init.zsh
fi

# Load hub alias
command -v hub >/dev/null 2>&1 && eval "$(hub alias -s)"

# Pathogen-like loader for plugins
find -L ~/.zsh/bundle -type f -name "*.plugin.zsh" | sort |
while read filename; do source "$filename"; done

# Load fzf after plugins to be able to override them
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use faster FZF grep command if possible
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
elif command -v ag >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='ag -g ""'
fi

# Load base16 theme
[ -z $BASE16_THEME ] && base16_solarized-dark

# }}}

# User configuration {{{

# Load user config
[[ -f "~/.zshrc.local" ]] && source "~/.zshrc.local"

# }}}
