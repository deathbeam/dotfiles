#!/usr/bin/bash -l
set -ex

echo '==> Installing Nvidia packages'
yay -S --noconfirm --mflags --skipinteg \
    dkms \
    nvidia-dkms nvidia-settings \
    nvidia-utils lib32-nvidia-utils \
    opencl-nvidia lib32-opencl-nvidia \
    libva-nvidia-driver

echo '==> Configuring Nvidia'
sudo systemctl enable \
    nvidia-suspend \
    nvidia-hibernate \
    nvidia-resume \
    nvidia-powerd
