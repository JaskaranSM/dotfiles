#!/usr/bin/env bash

TRACK_FILE="/tmp/i3_last_workspace"

# If the history file doesn't exist yet, default safely to workspace 1
if [ ! -f "$TRACK_FILE" ]; then
    PREV_WS="1"
else
    PREV_WS=$(cat "$TRACK_FILE")
fi

# Get the current active workspace number
CURRENT_WS=$(i3-msg -t get_workspaces | grep -o '"num":[0-9],"focused":true' | cut -d: -f2 | cut -d, -f1)

# Safety Check: If previous and current are somehow identical, stop to prevent loops
if [ "$CURRENT_WS" == "$PREV_WS" ]; then
    exit 0
fi

# 1. Look at all windows on the CURRENT workspace and move them to the PREVIOUS workspace
# 2. Switch your desktop view back to that PREVIOUS workspace instantly
i3-msg "[workspace=$CURRENT_WS] move container to workspace number $PREV_WS; workspace number $PREV_WS"
