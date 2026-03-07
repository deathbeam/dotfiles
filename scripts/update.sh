#!/usr/bin/bash -l
set -e
shopt -s nullglob globstar

arch-update
asdf plugin update --all
asdf install protonge latest
hyprpm update
