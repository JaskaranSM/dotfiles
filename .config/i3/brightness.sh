#!/bin/bash

# Change brightness based on argument (+10% or 10%-)
case $1 in
    up)
        brightnessctl set +10%
        ;;
    down)
        brightnessctl set 10%-
        ;;
esac

# Get the current brightness percentage
# brightnessctl returns something like "Current brightness: 1200 (60%)"
BRIGHTNESS=$(brightnessctl g | awk -v max=$(brightnessctl m) '{print int(($1/max)*100)}')

# Send brightness progress bar notification
# We use a different ID (-r 9994) so it doesn't conflict with the volume OSD
dunstify -a "changeBrightness" -u low -r 9994 -h int:value:"$BRIGHTNESS" "Brightness: ${BRIGHTNESS}%"
