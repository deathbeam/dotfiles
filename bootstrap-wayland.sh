#!/usr/bin/bash -l
set -ex

echo '==> Installing Wayland packages'
yay --noconfirm -S --mflags --skipinteg \
    hyprland xdg-desktop-portal-hyprland qt6-wayland \
    swaybg swaylock wl-clipboard cliphist slurp grim
