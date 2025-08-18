CACHE_FILE="$HOME/.cache/pass_env"
CACHE_AGE_MIN=60

# Refresh cache if missing or older than CACHE_AGE_MIN
if [ ! -f "$CACHE_FILE" ] || [ "$(find "$CACHE_FILE" -mmin +$CACHE_AGE_MIN)" ]; then
  print -n > "$CACHE_FILE"
  for secret in $(pass git ls-files | grep '^Env/' | sed 's|.gpg$||'); do
    varname=$(basename "$secret")
    value="$(pass "$secret")"
    print -r -- "export $varname='$value'" >> "$CACHE_FILE"
  done
fi

# Source cached exports
source "$CACHE_FILE"
