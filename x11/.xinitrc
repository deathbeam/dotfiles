#!/bin/zsh

# Load all other xinitrc files
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Load profile
source ~/.profile

# Set DPI
export DPI=96
export POLYBAR_BAR_HEIGHT=40
export GDK_SCALE=1
export QT_SCALE_FACTOR=1

if [[ -n $SCALE_FACTOR ]]; then
    export DPI=$(echo "$DPI * $SCALE_FACTOR" | bc)
    export POLYBAR_BAR_HEIGHT=$(echo "$POLYBAR_BAR_HEIGHT * $SCALE_FACTOR" | bc)
    export GDK_SCALE=$(echo "$GDK_SCALE * $SCALE_FACTOR" | bc)
    export QT_SCALE_FACTOR=$(echo "$QT_SCALE_FACTOR * $SCALE_FACTOR" | bc)
fi

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
xrandr --dpi ${DPI}
xrdb -D"DPI=$DPI" -merge ~/.Xresources

# Change mouse cursor from X11 X to normal one
xsetroot -cursor_name left_ptr

# Remap caps lock to control and escape
setxkbmap -option 'caps:ctrl_modifier' && xcape -e 'Caps_Lock=Escape' &

# Set gpg agent tty
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Set nice wallpaper
if command -v feh >/dev/null 2>&1; then
  feh --bg-scale ~/.wallpaper
fi

# Start autocutsel
if command -v autocutsel >/dev/null 2>&1; then
  autocutsel -s CLIPBOARD -fork &
fi

# Start location daemon
if [ -f /usr/lib/geoclue-2.0/demos/agent ]; then
  /usr/lib/geoclue-2.0/demos/agent &
fi

# Start notification daemon
if command -v dunst >/dev/null 2>&1; then
  dunst &
fi

# Start redshift
if command -v redshift-qt >/dev/null 2>&1; then
  redshift-qt &
fi

# Start dropbox
if command -v dropbox >/dev/null 2>&1; then
  dropbox start &
fi

# Start steam
if command -v steam >/dev/null 2>&1; then
  steam -silent &
fi

# Start discod
if command -v discord >/dev/null 2>&1; then
  discord --start-minimized &
fi

# Start udiskie
if command -v udiskie >/dev/null 2>&1; then
  udiskie --tray &
fi

# Start key manager daemon
if command -v sxhkd >/dev/null 2>&1; then
  sxhkd &
fi

st -e /bin/zsh -ic "tmux new-session -A -s default" &

# And finally, start our WM
exec bspwm
