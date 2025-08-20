log "Installing desktop packages"
packages=(
    alsa-utils
    vulkan-tools
    libva-utils
    brightnessctl
    fonts-meta-base
    terminus-font terminus-font-ttf ttf-terminus-nerd
    udiskie
    gammastep geoclue2
    dunst
    yambar-git
    alacritty
    gcr
    zathura zathura-pdf-mupdf
    qutebrowser python-adblock
    firefox firefox-tridactyl firefox-tridactyl-native
    gimp
    mpv subliminal yt-dlp
    vesktop-bin stremio
    gamescope steam steamtinkerlaunch lutris
    calibre
    youtube-music-bin
    gpu-screen-recorder
    jamesdsp
)
install_pkgs "${packages[@]}"

packages=(
    protonge
)
install_asdf_pkgs "${packages[@]}"

log "Configuring desktop"

# Add steamtinkerlaunch compat
steamtinkerlaunch compat add

# Enable bitmap fonts (we need them to correctly render Terminus)
if [ -f "/etc/fonts/conf.d/70-no-bitmaps.conf" ]; then
    sudo rm -f /etc/fonts/conf.d/70-no-bitmaps.conf
    fc-cache -f
fi

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop || true
