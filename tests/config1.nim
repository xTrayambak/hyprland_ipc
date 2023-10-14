import hyprland_ipc/[ctl, config, dispatch]

bindKey(
  @[mSuper, mShift],
  key("z"),
  DispatchType(kind: Exec, program: "foot")
)
