#!/usr/bin/env bash

# Fetch a list of currently active workspace numbers from i3's runtime engine
active_workspaces=$(i3-msg -t get_workspaces | grep -o '"num":[0-9]' | cut -d: -f2)

# Loop strictly through your designated workspaces (1 to 4)
for i in {1..4}; do
    # If the workspace number is not in the active list, it's free!
    if ! echo "$active_workspaces" | grep -q "$i"; then
        # Move the focused window to that free workspace
        i3-msg "move container to workspace number $i"
        # Instantly switch your focus to that workspace
        i3-msg "workspace number $i"
        exit 0
    fi
done

# Optional fallback: If 1-4 are totally full, do nothing safely
exit 1
