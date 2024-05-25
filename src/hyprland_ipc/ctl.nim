import std/[times, strformat], shared

proc reload* =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(kEmpty, "reload")
  )

  if not msg.success:
    raise newException(HyprlandDefect, "reload command returned non-ok status: " & msg.response)

proc kill* =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(kEmpty, "kill")
  )

  if not msg.success:
    raise newException(HyprlandDefect, "kill command returned non-ok status: " & msg.response)

proc setCursor*(theme: string, size: uint16) =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(kEmpty, fmt"setcursor {theme} {size}")
  )

  if not msg.success:
    raise newException(HyprlandDefect, "setcursor command returned non-ok status: " & msg.response)

type
  OutputBackends* = enum
    Wayland
    X11
    Headless
    Auto

proc create*(backend: OutputBackends) =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(kEmpty, fmt"output create {backend}")
  )

  if not msg.success:
    raise newException(HyprlandDefect, "output create command returned non-ok status: " & msg.response)

proc remove*(name: string) =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(kEmpty, fmt"output remove {name}")
  )

  if not msg.success:
    raise newException(HyprlandDefect, "output remove command returned non-ok status: " & msg.response)

type
  NotifyIcon* = enum
    NoIcon = -1
    Warning = 0
    Info = 1
    Hint = 2
    Error = 3
    Confused = 4
    Ok = 5

  Color* = ref object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

proc `$`*(color: Color): string =
  fmt"rgba({color.r:02x}{color.g:02x}{color.b:02x}{color.a:02x})"

proc notify*(icon: NotifyIcon, time: Duration, color: Color, msg: string) =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(
      kEmpty,
      fmt"notify {icon.int8} {time.inMicroseconds()} {color} {msg}"
    )
  )

  if not msg.success:
    raise newException(HyprlandDefect, "notify banner command returned non-ok status: " & msg.response)

type
  PropKind* = enum
    kAnimStyle
    kRounding
    kForceNoBlur
    kForceOpaque
    kForceOpaqueOverriden
    kForceAllowsInput
    kForceNoAnims
    kForceNoBorder
    kForceNoShadow
    kWindowDanceCompat
    kNoMaxSize
    kDimAround
    kAlphaOverride
    kAlpha
    kAlphaInactiveOverride
    kAlphaInactive
    kActiveBorderColor
    kInactiveBorderColor

  Prop* = ref object
    case kind*: PropKind
    of kAnimStyle:
      style*: string
    of kRounding:
      rFactor*: int64
      rLocked*: bool
    of kForceNoBlur:
      # TODO: document these
      bBool1*: bool
      bLocked*: bool
    of kForceOpaque:
      oBool1*: bool
      oLocked*: bool
    of kForceOpaqueOverriden:
      ooBool1*: bool
      ooLocked*: bool
    of kForceAllowsInput:
      faBool1*: bool
      faLocked*: bool
    of kForceNoAnims:
      aBool1*: bool
      aLocked*: bool
    of kForceNoBorder:
      nbBool1*: bool
      nbLocked*: bool
    of kForceNoShadow:
      nsBool1*: bool
      nsLocked*: bool
    of kWindowDanceCompat:
      wdBool1*: bool
      wdLocked*: bool
    of kNoMaxSize:
      msBool1*: bool
      msLocked*: bool
    of kDimAround:
      daBool1*: bool
      daLocked*: bool
    of kAlphaOverride:
      aoBool1*: bool
      aoLocked*: bool
    of kAlpha:
      kaFactor*: float32
      kaLocked*: bool
    of kAlphaInactiveOverride:
      ioBool1*: bool
      ioLocked*: bool
    of kAlphaInactive:
      aiFactor*: bool
      aiLocked*: bool
    of kActiveBorderColor:
      bcColor*: Color
      bcLocked*: bool
    of kInactiveBorderColor:
      ibColor*: Color
      ibLocked*: bool

proc `$`*(prop: Prop): string =
  result = case prop.kind:
    of kAnimStyle:
      fmt"animationstyle {prop.style}"
    of kRounding:
      fmt"rounding {prop.rFactor} {prop.rLocked}"
    of kForceNoBlur:
      fmt"forcenoblur {prop.bBool1} {prop.bLocked}"
    of kForceOpaque:
      fmt"forceopaque {prop.oBool1} {prop.oLocked}"
    of kForceOpaqueOverriden:
      fmt"forceopaqueoverriden {prop.ooBool1} {prop.ooLocked}"
    of kForceAllowsInput:
      fmt"forceallowsinput {prop.faBool1} {prop.faLocked}"
    of kForceNoAnims:
      fmt"forcenoanims {prop.aBool1} {prop.aLocked}"
    of kForceNoBorder:
      fmt"forcenoborder {prop.nbBool1} {prop.nbLocked}"
    of kForceNoShadow:
      fmt"forcenoshadow {prop.nsBool1} {prop.nsLocked}"
    of kWindowDanceCompat:
      fmt"windowdancecompat {prop.wdBool1} {prop.wdLocked}"
    of kNoMaxSize:
      fmt"nomaxsize {prop.msBool1} {prop.msLocked}"
    of kDimAround:
      fmt"dimaround {prop.daBool1} {prop.daLocked}"
    of kAlphaOverride:
      fmt"alphaoverride {prop.aoBool1} {prop.aoLocked}"
    of kAlpha:
      fmt"alpha {prop.kaFactor} {prop.kaLocked}"
    of kAlphaInactiveOverride:
      fmt"alphainactiveoverride {prop.ioBool1} {prop.ioLocked}"
    of kAlphaInactive:
      fmt"alphainactive {prop.aiFactor} {prop.aiLocked}"
    of kActiveBorderColor:
      fmt"alphabordercolor {prop.bcColor} {prop.bcLocked}"
    of kInactiveBorderColor:
      fmt"inactivebordercolor {prop.ibColor} {prop.ibLocked}"

proc setProp*(ident: string, prop: Prop) =
  let msg = writeToSocket(
    getSocketPath(kCommand),
    command(
      kEmpty,
      fmt"setprop {ident} {prop}"
    )
  )
    
  if not msg.success:
    raise newException(HyprlandDefect, "setprop returned non-ok status: " & msg.response)
