log "Installing gamedev packages"
packages=(
  aseprite
  magicavoxel
  godot-git
  python-gdtoolkit
  trenchbroom-bin
  qt5-svg
)
install_pkgs "${packages[@]}"
