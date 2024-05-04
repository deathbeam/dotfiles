#!/usr/bin/bash -l
set -ex

echo '==> Installing Nvidia packages'
yay --noconfirm -S --mflags --skipinteg \
    nvidia-beta nvidia-utils-beta lib32-nvidia-utils-beta libva-nvidia-driver

echo '==> Configuring Nvidia'
sudo systemctl enable nvidia-powerd.service
