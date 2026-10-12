#!/bin/bash

# 1. Clear out any stuck ghost processes from previous attempts
killall flameshot 2>/dev/null

# 2. Run flameshot natively, but completely break its connection to DBus notifications.
# This prevents the Qt event loop from panicking and locking up your CPU thread.
env DBUS_SESSION_BUS_ADDRESS="" flameshot gui

# 3. Give your clipboard a brief moment to finish syncing after the GUI closes
#sleep 0.5

# 4. Drop the hammer to guarantee it terminates cleanly
#killall flameshot 2>/dev/null
