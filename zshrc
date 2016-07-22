# Install Prezto if not installed
[[ ! -d ~/.zprezto ]] &&
 git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Load Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fix paths
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

# Manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Aliases to config files
alias config-zsh="$EDITOR ~/.zshrc"
alias config-prezto="$EDITOR ~/.zpreztorc"
alias config-vim="$EDITOR ~/.vimrc"

