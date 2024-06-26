#!/usr/bin/bash -l
set -ex

echo '==> Installing Nvidia packages'
yay -S --noconfirm --mflags --skipinteg \
    dkms nvidia-beta-dkms nvidia-settings-beta \
    nvidia-utils-beta lib32-nvidia-utils-beta \
    opencl-nvidia-beta lib32-opencl-nvidia-beta \
    libva-nvidia-driver

echo '==> Configuring Nvidia'
sudo systemctl enable \
    nvidia-suspend \
    nvidia-hibernate \
    nvidia-resume \
    nvidia-powerd
