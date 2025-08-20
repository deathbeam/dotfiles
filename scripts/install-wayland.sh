log "Installing Wayland packages"
packages=(
    xorg-xwayland
    xclip
    qt5-wayland
    qt6-wayland
    hyprland
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
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
