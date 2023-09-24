import std/times, hyprland_ipc/[ctl, dispatch, keyword]

# reload()
#[notify(
  Info, 
  initDuration(seconds = 30), 
  Color(r: 8, g: 8, b: 8, a: 8), 
  "Hello from Nim!"
) ]#

# setKeyword("decoration:blur:enabled", "true")
dispatch(
  DispatchType(
    kind: ToggleFullscreen
  )
)
