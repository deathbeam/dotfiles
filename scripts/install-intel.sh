log "Installing Intel packages"
packages=(
  vulkan-intel
  lib32-vulkan-intel
  thermald-git
)
install_pkgs "${packages[@]}"
