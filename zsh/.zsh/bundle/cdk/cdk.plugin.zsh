_cdk_chpwd_handler () {
  emulate -L zsh
  command -v k >/dev/null 2>&1 && k
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _cdk_chpwd_handler
_cdk_chpwd_handler
