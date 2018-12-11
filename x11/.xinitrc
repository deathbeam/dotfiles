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

# Set HiDPI
if [[ -z "${LDPI}" ]]; then
  xrandr --dpi 96
  export QT_AUTO_SCREEN_SCALE_FACTOR=1
  export GDK_SCALE=2
  export POLYBAR_BAR_HEIGHT=80

  # Update XResouces
  xrdb -merge ~/.Xresources
else
  export POLYBAR_BAR_HEIGHT=40
fi

# Change mouse cursor from X11 X to normal one
xsetroot -cursor_name left_ptr

# Load custom keyboard mappings
xmodmap ~/.xmodmap

# Update mouse acceleration
xinput --set-prop 10 'libinput Accel Speed' 0.5 # touchpad
xinput --set-prop 15 'libinput Accel Speed' 0.5 # mouse

# Set nice wallpaper
if command -v feh >/dev/null 2>&1; then
  feh --bg-scale ~/.wallpaper
fi

# Start autocutsel
if command -v autocutsel >/dev/null 2>&1; then
  autocutsel -fork &
fi

# Start clipboard manager daemon
if [ -f ~/.config/dmenu/clipmenu/clipmenud ]; then
  ~/.config/dmenu/clipmenu/clipmenud &
fi

# Start notification daemon
if command -v dunst >/dev/null 2>&1; then
  dunst &
fi

# Start music manager daemon
if command -v mopidy >/dev/null 2>&1; then
  mopidy &
fi

# Start bitlbee
if command -v bitlbee >/dev/null 2>&1; then
  bitlbee &
fi

# Start redshift
if command -v redshift-gtk >/dev/null 2>&1; then
  redshift-gtk &
fi

# Start dropbox
if command -v dropbox >/dev/null 2>&1; then
  dropbox start &
fi

# Now, open terminal window
if command -v st >/dev/null 2>&1; then
  st &
fi

# Start key manager daemon
if command -v sxhkd >/dev/null 2>&1; then
  sxhkd &
fi

# And finally, start our WM
exec bspwm
