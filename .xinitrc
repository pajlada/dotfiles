xset r rate 175 50

# your mileage may vary with this file, the options below are very personalized for my current setup
setxkbmap -option caps:none pajlada
xrandr --dpi 90
xrandr --output DP-0 --mode 2560x1440 --pos 0x2400
xrandr --output DP-2 --mode 2560x1440 --pos 2560x2400
xrandr --output DP-4 --mode 3840x2160 --rotate left --pos 5120x0
exec i3
