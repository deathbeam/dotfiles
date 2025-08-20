#!/usr/bin/bash -l
set -e
shopt -s nullglob globstar

log() {
  echo -e "\033[1;32m==> $*\033[0m"
}

install_pkgs() {
  yay -Sy --noconfirm --mflags --skipinteg "${@}"
}

instal_python_pkgs() {
  pip3 install --user --break-system-packages
}

instal_npm_pkgs() {
  mkdir -p ~/.npm-global
  npm config set prefix "$HOME/.npm-global"
  npm install -g "${@}"
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

append_pacman_option() {
  local option="$1"
  if ! grep -q "^$option" /etc/pacman.conf; then
    sudo sed -i "/^\[options\]/a $option" /etc/pacman.conf
  fi
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
