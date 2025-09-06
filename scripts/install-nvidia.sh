log "Installing Nvidia packages"
packages=(
  dkms
  nvidia-open-dkms
  nvidia-settings
  nvidia-utils
  lib32-nvidia-utils
  opencl-nvidia
  lib32-opencl-nvidia
  libva-nvidia-driver
  nvidia-container-toolkit
)
install_pkgs "${packages[@]}"

log "Enabling Nvidia services"
services=(
  nvidia-suspend
  nvidia-hibernate
  nvidia-resume
  nvidia-powerd
)
enable_services "${services[@]}"
