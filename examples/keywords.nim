#[
  An almost complete example of src/hyprland_ipc/keyword.nim
]#
import hyprland_ipc/keyword

# Disable blur
setKeyword(
  "decoration:blur:enable",
  false
)

# Set gaps to 8
setKeyword(
  "general:gaps_in",
  8
)

# Disable animations
setKeyword(
  "animations:enabled",
  false
)
