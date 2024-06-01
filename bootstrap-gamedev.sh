#!/usr/bin/bash -l
set -ex

echo '==> Installing Gamedev packages'
yay -S --noconfirm --mflags --skipinteg \
    godot-git \
    aseprite \
    trenchbroom-bin qt5-svg
