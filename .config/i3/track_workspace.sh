#!/usr/bin/env bash

# File to store the workspace history
TRACK_FILE="/tmp/i3_last_workspace"

# Initialize the file with workspace 1
echo "1" > "$TRACK_FILE"

# Subscribe to i3 workspace events using the native IPC interface
i3-msg -t subscribe '["workspace"]' | while read -r line; do
    # Check if the event is a focus change
    if echo "$line" | grep -q '"change":"focus"'; then
        # Extract the OLD workspace number that we just left
        old_ws=$(echo "$line" | grep -o '"old":{[^}]*}' | grep -o '"num":[0-9]' | cut -d: -f2)
        
        # If an old workspace number exists cleanly, save it
        if [ ! -z "$old_ws" ]; then
            echo "$old_ws" > "$TRACK_FILE"
        fi
    fi
done
