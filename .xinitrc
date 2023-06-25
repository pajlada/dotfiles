#!/bin/sh

# your mileage may vary with this file
# the options below are very personalized for my current setup

# Disable screen saver
xset s off

# Turn off monitor after 25 minuters
xset dpms 0 0 1500

# Load my custom keyboard layout (basically standard US layout, but altgr+['; = åäö)
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

# Hide mouse when typing
# xbanish & disown

# Clipboard manager
parcellite -n & disown

# DPI
xrandr --dpi 96

# TV
# xrandr --output HDMI-0 --mode 1920x1080 --pos 2160x0
xrandr --output HDMI-0 --auto

# 24" 4k        left
xrandr --output DP-0 --mode 3840x2160 --rotate right --pos 0x0

# 27" 1440p     center
xrandr --output DP-4 --primary --mode 2560x1440 --pos 2160x2400

# 27" 1440p     right
xrandr --output DP-2 --mode 2560x1440 --pos 4720x2400

xsetroot -solid "#333333"

# Load hostname-specific config
[ -x "$HOME/.config/xinit/xinitrc-$HOST" ] && . "$HOME/.config/xinit/xinitrc-$HOST"

# Load configs from the xinitrc.d directory
if [ -d "$HOME/.config/xinit/xinitrc.d" ]; then
  for f in "$HOME/.config/xinit/xinitrc.d/"?*.sh; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

exec i3
