#!/usr/bin/bash -l
set -e
shopt -s nullglob globstar

log() {
  echo -e "\033[1;32m==> $*\033[0m"
}

clone_repo() {
  local repo="$1"
  local dir="$2"
  [ -d "$dir" ] || mkdir -p "$dir" && git clone "$repo" "$dir"
}

install_pkgs() {
  yay -Sy --noconfirm --mflags --skipinteg "${@}"
}

enable_services() {
  sudo systemctl enable "${@}"
}

enable_groups() {
  for group in "$@"; do
    sudo groupadd -f "$group"
    sudo usermod -aG "$group" "$USER"
  done
}

append_config() {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" || echo "$line" | sudo tee -a "$file" > /dev/null
}

symlink() {
  local src="$1"
  local dest="$2"
  [ -e "$dest" ] || ln -sf "$src" "$dest"
}

set_default_shell() {
  local shell="$1"
  if [ "$SHELL" != "$shell" ]; then
    chsh -s "$shell" "$USER"
  fi
}

set_default_browser() {
  local browser="$1"
  current=$(xdg-settings get default-web-browser)
  [ "$current" = "$browser" ] || xdg-settings set default-web-browser "$browser"
}

script_dir="$(dirname "$0")"
profile_scripts=("$script_dir"/install-*.sh)

if [ "$#" -eq 0 ]; then
  log "Available profiles:"
  for script in "${profile_scripts[@]}"; do
    echo "  $(basename "$script" .sh | sed 's/install-//')"
  done
  exit 0
fi

for arg in "$@"; do
  match="$script_dir/install-$arg.sh"
  if [ -f "$match" ]; then
    log "Running profile: $arg"
    source "$match"
  else
    log "Profile not found: $arg"
    exit 1
  fi
done
