# If not configured its fine
if [[ -z "$ENV_CACHE_FILE" ]]; then
  return
fi

# Load cache if it exists
if [[ -f "$ENV_CACHE_FILE" ]]; then
  source "$ENV_CACHE_FILE"
fi

# Regenerate env cache from password-store Env/ directory
function update_env_cache() {
  local prefix=${PASSWORD_STORE_DIR:-$HOME/.password-store}
  local pwdir="$prefix/Env"

  if [[ ! -d "$pwdir" ]]; then
    echo "update_env_cache: $pwdir not found" >&2
    return 1
  fi

  local password_files=( "$pwdir"/**/*.gpg(N) )
  [[ ${#password_files} -eq 0 ]] && { echo "update_env_cache: no .gpg files found in $pwdir" >&2; return 1 }

  password_files=( "${password_files[@]#"$prefix/"}" )
  password_files=( "${password_files[@]%.gpg}" )

  : > "$ENV_CACHE_FILE"

  local varname value rc=0
  for password_file in "${password_files[@]}"; do
    varname=$(basename "$password_file")
    echo "update_env_cache: decrypting $password_file ..." >&2
    value="$(pass "$password_file")" || {
      echo "update_env_cache: failed to decrypt $password_file (skipping)" >&2
      rc=1
      continue
    }
    print -r -- "export $varname='$value'" >> "$ENV_CACHE_FILE"
  done

  if [[ $rc -eq 0 ]]; then
    echo "update_env_cache: done, ${#password_files[@]} vars cached" >&2
  else
    echo "update_env_cache: completed with errors (check above)" >&2
  fi

  return $rc
}
