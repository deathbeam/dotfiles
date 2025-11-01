log "Installing desktop packages"
packages=(
    alsa-utils
    vulkan-tools
    libva-utils
    brightnessctl
    gcr
    fonts-meta-base terminus-font terminus-font-ttf ttf-terminus-nerd
    udiskie
    imagemagick imv
    gammastep geoclue
    jamesdsp
    gpu-screen-recorder-git
    dunst
    cava
    zathura zathura-pdf-mupdf libreoffice-fresh gimp # document/image viewers and editors
    qutebrowser python-adblock python-readability-lxml # browser
    mpv subliminal yt-dlp # video player and downloader
    gamescope steam steamtinkerlaunch-git wine winetricks umu-launcher lutris # gaming
    stremio youtube-music-bin # media streaming
    vesktop-bin # discord
    calibre # ebook management
)
install_pkgs "${packages[@]}"

packages=(
    protonge
)
install_asdf_pkgs "${packages[@]}"

log "Configuring desktop"

# Enable ntsync
echo ntsync | sudo tee /etc/modules-load.d/ntsync.conf

# Add steamtinkerlaunch compat
steamtinkerlaunch compat add

# Enable bitmap fonts (we need them to correctly render Terminus)
if [ -f "/etc/fonts/conf.d/70-no-bitmaps.conf" ]; then
    sudo rm -f /etc/fonts/conf.d/70-no-bitmaps.conf
    fc-cache -f
fi

# pipewire crackling sometimes
sudo mkdir -p /etc/pipewire/pipewire.conf.d
echo 'context.properties = {
    default.clock.quantum     = 2048
    default.clock.min-quantum = 1024
    default.clock.max-quantum = 4096
}' | sudo tee /etc/pipewire/pipewire.conf.d/99-quantum.conf > /dev/null
systemctl --user restart pipewire pipewire-pulse || true

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop || true
