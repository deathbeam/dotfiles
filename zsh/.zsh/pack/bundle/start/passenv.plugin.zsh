CACHE_FILE="$HOME/.cache/pass_env"
CACHE_AGE_MIN=60

# Source the cache file if it exists
if [[ -f "$CACHE_FILE" ]]; then
  source "$CACHE_FILE"
fi

# Refresh cache if missing or older than CACHE_AGE_MIN, in background
if [ ! -f "$CACHE_FILE" ] || [ "$(find "$CACHE_FILE" -mmin +$CACHE_AGE_MIN)" ]; then
  (
    prefix=${PASSWORD_STORE_DIR-~/.password-store}
    password_files=( "$prefix"/Env/**/*.gpg )
    password_files=( "${password_files[@]#"$prefix"/}" )
    password_files=( "${password_files[@]%.gpg}" )
    > "$CACHE_FILE"
    for password_file in "${password_files[@]}"; do
      varname=$(basename "$password_file")
      value="$(pass "$password_file")"
      print -r -- "export $varname='$value'" >> "$CACHE_FILE"
    done
  ) < /dev/null &
fi
