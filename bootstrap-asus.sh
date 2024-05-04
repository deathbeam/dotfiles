#!/usr/bin/bash -l
set -ex

echo '==> Setting up g14 repository'
sudo tee -a /etc/pacman.conf <<EOF
[g14]
Server = https://arch.asus-linux.org
EOF

pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35

echo '==> Installing Asus packages'
yay --noconfirm -Sy --mflags --skipinteg \
    asusctl power-profiles-daemon supergfxctl switcheroo-control rog-control-center

echo '==> Configuring Asus'
sudo systemctl enable power-profiles-daemon
sudo systemctl enable supergfxd
sudo systemctl enable switcheroo-control
