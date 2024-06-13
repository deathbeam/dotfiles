#!/usr/bin/bash -l
set -ex

echo '==> Installing Wayland packages'
yay -S --noconfirm --mflags --skipinteg \
    hyprwayland-scanner-git hyprutils-git hyprland-git xorg-xwayland-git xdg-desktop-portal-hyprland qt6-wayland \
    swaybg swaylock wl-clipboard cliphist slurp grim
