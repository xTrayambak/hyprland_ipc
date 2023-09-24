import hyprland_ipc

assert writeToSocket(
  getSocketPath(kCommand),
  command(
    kEmpty,
    "wrwerwejir"
  )
).success == false, "Hyprland is drunk as this should always be false!"
