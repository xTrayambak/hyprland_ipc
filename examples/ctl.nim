## Example of almost everything the `ctl` module provides.

import std/times
import hyprland_ipc/ctl

# Reload Hyprland
reload()

# Kill Hyprland
kill()

# Set cursor theme
setCursor("Breeze", 16)

# Send a notification saying "Hello from Nim!" that will linger for 30 seconds.
# This is not sent through your notification daemon, rather through Hyprland's
# built-in notifications system
notify(
  NoIcon,
  initDuration(seconds = 30),
  Color(r: 8, g: 8, b: 8, a: 8),
  "Hello from Nim!"
)
