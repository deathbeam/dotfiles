#!/usr/bin/bash -l
set -ex

echo '==> Installing Wayland packages'
yay -S --noconfirm --mflags --skipinteg \
    hyprland-git xorg-xwayland-git xdg-desktop-portal-hyprland qt6-wayland \
    swaybg swaylock wl-clipboard cliphist slurp grim
