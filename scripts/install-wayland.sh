log "Installing Wayland packages"
packages=(
    xorg-xwayland
    xclip
    qt5-wayland
    qt6-wayland
    hyprland
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    swaybg
    swaylock
    wl-clipboard
    cliphist
    grim
    slurp
    satty
    cpio
)
install_pkgs "${packages[@]}"

log "Configuring Hyprland"
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins || true
hyprpm enable hyprexpo

services=(
    hyprpolkitagent
)
enable_user_services "${services[@]}"
