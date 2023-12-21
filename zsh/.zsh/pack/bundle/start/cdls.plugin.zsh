_cdls_chpwd_handler () {
  emulate -L zsh
  ls -A --color=always
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _cdls_chpwd_handler
_cdls_chpwd_handler
