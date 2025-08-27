log "Installing desktop packages"
packages=(
    alsa-utils
    vulkan-tools
    libva-utils
    brightnessctl
    gcr
    fonts-meta-base terminus-font terminus-font-ttf ttf-terminus-nerd
    udiskie
    gammastep geoclue
    jamesdsp
    gpu-screen-recorder
    dunst
    yambar-git
    alacritty
    zathura zathura-pdf-mupdf libreoffice-fresh gimp
    qutebrowser python-adblock python-readability-lxml
    # firefox firefox-tridactyl firefox-tridactyl-native
    mpv subliminal yt-dlp
    gamescope steam steamtinkerlaunch-git wine winetricks lutris dxvk-bin
    qbittorrent stremio youtube-music-bin
    vesktop-bin
    calibre
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
