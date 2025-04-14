_source_env() {
  if [[ ! -f ".env" ]]; then
    return
  fi

  setopt localoptions allexport
  source .env
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _source_env
_source_env
