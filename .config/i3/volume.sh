#!/bin/bash

# Change volume based on argument (+5%, -5%, or toggle)
# This script uses 'pactl' (works for both PulseAudio and PipeWire)
case $1 in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
esac

# Get the current volume numeric value
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)
IS_MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$IS_MUTE" = "yes" ]; then
    # Send muted notification
    dunstify -a "changeVolume" -u low -r 9993 -i audio-volume-muted "Muted"
else
    # Send volume progress bar notification
    dunstify -a "changeVolume" -u low -r 9993 -h int:value:"$VOLUME" "Volume: ${VOLUME}%"
    # Note: If your icon theme supports it, you can add -i audio-volume-high
fi
