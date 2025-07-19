#!/usr/bin/bash -l
set -ex

echo '==> Installing Wayland packages'
yay -S --noconfirm --mflags --skipinteg \
    xorg-xwayland xclip \
    qt5-wayland qt6-wayland \
    hyprland xdg-desktop-portal-hyprland \
    swaybg swaylock wl-clipboard cliphist grim slurp satty \
    cpio

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
