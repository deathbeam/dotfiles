log "Setting up g14 repository"
append_config '[g14]' /etc/pacman.conf
append_config 'Server = https://arch.asus-linux.org' /etc/pacman.conf
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654887F17D497FEFE3DB448B15A6B0E9A3FA35

log 'Installing Asus packages'
packages=(
  asusctl
  rog-control-center
)
install_pkgs "${packages[@]}"

log 'Enabling Asus services'
services=(
  asusd
)
enable_services "${services[@]}"
