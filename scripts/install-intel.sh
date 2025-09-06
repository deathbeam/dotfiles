log "Installing Intel packages"
packages=(
  vulkan-intel
  lib32-vulkan-intel
)
install_pkgs "${packages[@]}"
