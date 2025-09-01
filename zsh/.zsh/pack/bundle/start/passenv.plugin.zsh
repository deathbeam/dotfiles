CACHE_FILE="$HOME/.cache/pass_env"
CACHE_AGE_MIN=60

# Refresh cache if missing or older than CACHE_AGE_MIN
if [ ! -f "$CACHE_FILE" ] || [ "$(find "$CACHE_FILE" -mmin +$CACHE_AGE_MIN)" ]; then
  print -n > "$CACHE_FILE"

  prefix=${PASSWORD_STORE_DIR-~/.password-store}
  password_files=( "$prefix"/Env/**/*.gpg )
  password_files=( "${password_files[@]#"$prefix"/}" )
  password_files=( "${password_files[@]%.gpg}" )
  for password_file in "${password_files[@]}"; do
    varname=$(basename "$password_file")
    value="$(pass "$password_file")"
    print -r -- "export $varname='$value'" >> "$CACHE_FILE"
  done
fi

# Source cached exports
source "$CACHE_FILE"
