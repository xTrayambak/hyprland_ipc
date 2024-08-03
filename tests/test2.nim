import std/times 
import hyprland_ipc/[ctl, dispatch, keyword]

# reload()
#[notify(
  Info, 
  initDuration(seconds = 30), 
  Color(r: 8, g: 8, b: 8, a: 8), 
  "Hello from Nim!"
) ]#

setKeyword("decoration:blur:enabled", false)
dispatch(
  DispatchType(
    kind: Exec,
    program: "foot"
  )
)
