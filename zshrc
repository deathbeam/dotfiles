# Install z.sh if not installed
[[ ! -d ~/.lib/z ]] &&
  git clone https://github.com/rupa/z ~/.lib/z

# Load z.sh
[[ -s ~/.lib/z/z.sh ]] &&
  source ~/.lib/z/z.sh

# Install Prezto if not installed
[[ ! -d ~/.zprezto ]] &&
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Load Prezto
[[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]] &&
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# Fix paths
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

# Manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR="vim"
export VISUAL="$EDITOR"

# Aliases to config files
alias config-zsh="$EDITOR ~/.zshrc"
alias config-prezto="$EDITOR ~/.zpreztorc"
alias config-vim="$EDITOR ~/.vimrc"

# Awesome Star Wars MOTD
motd[1]=$(echo "$USER, I am your father!" | cowsay -f vader-koala)
motd[2]=$(echo "He told me enough! He told me you killed him!" | cowsay -f luke-koala)
rand=$[$RANDOM % 2 + 1]
echo $motd[$rand]
