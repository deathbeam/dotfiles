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
    grim-hyprland-git
    slurp
    satty
    cpio
    foot
    quickshell-git
)
install_pkgs "${packages[@]}"

log "Configuring Hyprland"
services=(
    hyprpolkitagent
)
enable_user_services "${services[@]}"

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins || true
hyprpm enable hyprwinwrap
