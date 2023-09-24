#[
  An example of almost everything from src/hyprland_ipc/dispatch.nim
]#
import hyprland_ipc/dispatch

# Execute kitty (non-blocking)
dispatch(
  DispatchType(
    kind: Exec,
    program: "kitty"
  )
)

# Make the currently active window toggle its floating state
dispatch(
  DispatchType(
    exec: ToggleFloating
  )
)
