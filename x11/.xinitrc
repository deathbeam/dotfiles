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

# Start VirtualBox guest additions
if command -v VBoxClient-all >/dev/null 2>&1; then
  VBoxClient-all
fi

# Set DPI
if [[ -z "${HDPI}" ]]; then
  xrandr -s 1920x1080
  export DPI=96
  export POLYBAR_BAR_HEIGHT=40
else
  export GDK_SCALE=2
  export GDK_DPI_SCALE=0.5
  export DPI=196
  export POLYBAR_BAR_HEIGHT=80
fi

xrandr --dpi ${DPI}
xrdb -D"DPI=$DPI" -merge ~/.Xresources

# Change mouse cursor from X11 X to normal one
xsetroot -cursor_name left_ptr

# Remap caps lock to control and escape
setxkbmap -option 'caps:ctrl_modifier' && xcape -e 'Caps_Lock=Escape' &

# Update mouse stuff
xinput disable 'Wacom HID 50F0 Finger touch' # disable touch screen
xinput --set-prop 'MSFT0001:02 06CB:7F8F Touchpad' 'libinput Accel Speed' 0 # touchpad
xinput --set-prop 15 'libinput Accel Speed' 0 # mouse

# Set nice wallpaper
if command -v feh >/dev/null 2>&1; then
  feh --bg-scale ~/.wallpaper
fi

# Start autocutsel
if command -v autocutsel >/dev/null 2>&1; then
  autocutsel -s CLIPBOARD -fork &
  autocutsel -s PRIMARY -fork &
fi

# Start clipboard manager daemon
if command -v clipmenud >/dev/null 2>&1; then
  clipmenud &
fi

# Start location daemon
if [ -f /usr/lib/geoclue-2.0/demos/agent ]; then
  /usr/lib/geoclue-2.0/demos/agent &
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
if command -v redshift-qt >/dev/null 2>&1; then
  redshift-qt &
fi

# Start dropbox
if command -v dropbox >/dev/null 2>&1; then
  dropbox start &
fi

# Start udiskie
if command -v udiskie >/dev/null 2>&1; then
  udiskie --tray &
fi

# Start key manager daemon
if command -v sxhkd >/dev/null 2>&1; then
  sxhkd &
fi

# And finally, start our WM
exec bspwm
