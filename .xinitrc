# your mileage may vary with this file
# the options below are very personalized for my current setup

xset r rate 175 50

setxkbmap -option caps:none pajlada
xrandr --dpi 90

# TV
xrandr --output HDMI-0 --mode 1920x1080 --pos 2160x0

# 24" 4k        left
xrandr --output DP-0 --mode 3840x2160 --rotate left --pos 0x0

# 27" 1440p     center
xrandr --output DP-2 --mode 2560x1440 --pos 2160x2400

# 27" 1440p     right
xrandr --output DP-4 --mode 2560x1440 --pos 4720x2400

exec i3
