#!/usr/bin/bash -l
set -ex

echo '==> Installing Wayland packages'
yay -S --asdeps --noconfirm --mflags --skipinteg \
    hyprutils-git hyprlang-git hyprcursor-git hyprwayland-scanner-git

yay -S --noconfirm --mflags --skipinteg \
    hyprland-git xorg-xwayland xdg-desktop-portal-hyprland qt6-wayland \
    swaybg swaylock wl-clipboard cliphist slurp grim
