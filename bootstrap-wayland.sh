#!/usr/bin/bash -l
set -ex

echo '==> Installing Wayland packages'
yay -S --noconfirm --mflags --skipinteg \
    hyprland xorg-xwayland xclip xdg-desktop-portal-hyprland qt5-wayland qt6-wayland \
    swaybg swaylock wl-clipboard cliphist grim slurp hyprpicker hyprshot satty \
    cpio

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
