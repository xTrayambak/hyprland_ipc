import std/[options, strutils, strformat]
import shared

type
  WindowIdentifierKind* = enum
    ## The identifier type to use.
    kAddress
    kClassRegex
    kTitle
    kProcessId

  SwapWithMasterParam* = enum
    Master
    Child
    Auto

  FocusMasterParam* = enum
    mpMaster
    mpAuto

  WindowIdentifier* = ref object
    case kind*: WindowIdentifierKind
    of kAddress:
      address*: Address
    of kClassRegex:
      expr*: string
    of kTitle:
      title*: string
    of kProcessId:
      pid*: uint32

  FullscreenType* = enum
    Real
    Maximize
    NoParam

  Direction* = enum
    Up
    Down
    Right
    Left

  PositionKind* = enum
    kDelta
    kExact

  Position* = ref object
    case kind*: PositionKind
    of kDelta:
      dx*: int16
      dy*: int16
    of kExact:
      ex*: int16
      ey*: int16

  CycleDirection* = enum
    Next
    Previous

  WindowSwitchDirection* = enum
    Back
    Forward

  WorkspaceOptions* = enum
    AllPseudo
    AllFloat

  WorkspaceIdentifierWithSpecialKind* = enum
    kWorkspaceId
    kRelative
    kRelativeMonitor
    kRelativeOpen
    kPrev
    kEmpty
    kName
    kSpecial

  WorkspaceIdentifierKind* = enum
    wkWorkspaceId
    wkRelative
    wkRelativeMonitor
    wkRelativeOpen
    wkPrev
    wkEmpty
    wkName

  WorkspaceIdentifier* = ref object
    case kind*: WorkspaceIdentifierKind
    of wkWorkspaceId:
      wid*: int32
    of wkRelative:
      rInt*: int32
    of wkRelativeMonitor:
      rmInt*: int32
    of wkRelativeOpen:
      roInt*: int32
    of wkPrev:
      pInt*: int32
    of wkEmpty:
      eInt*: int32
    of wkName:
      name*: string

  WorkspaceIdentifierWithSpecial* = ref object
    case kind*: WorkspaceIdentifierWithSpecialKind
    of kWorkspaceId:
      wId*: int32
    of kRelative:
      rId*: int32
    of kRelativeMonitor:
      mId*: int32
    of kRelativeOpen:
      oId*: int32
    of kName:
      name*: string
    of kSpecial:
      sName*: Option[string]
    else:
      discard

  MonitorIdentifierKind* = enum
    ikDirection
    ikId
    ikName
    ikCurrent
    ikRelative

  MonitorIdentifier* = ref object
    case kind*: MonitorIdentifierKind
    of ikDirection:
      direction*: Direction
    of ikId:
      id*: uint8
    of ikRelative:
      rId*: int32
    of ikName:
      name*: string
    else:
      discard

  WindowMoveKind* = enum
    mkMonitor
    mkDirection

  WindowMove* = ref object
    case kind*: WindowMoveKind
    of mkMonitor:
      monitor*: MonitorIdentifier
    of mkDirection:
      direction*: Direction

  DispatchTypeKind* = enum
    Custom
    SetCursor
    Exec
    Pass
    Global
    KillActiveWindow
    CloseWindow
    Workspace
    MoveToWorkspace
    MoveToWorkspaceSilent
    MoveFocusedWindowToWorkspace
    MoveFocusedWindowToWorkspaceSilent
    ToggleFloating
    ToggleFullscreen
    ToggleFakeFullscreen
    ToggleDPMS
    TogglePseudo
    TogglePin
    MoveFocus
    MoveWindow
    CenterWindow
    ResizeActive
    MoveActive
    ResizeWindowPixel
    MoveWindowPixel
    CycleWindow
    SwapWindow
    FocusWindow
    FocusMonitor
    ChangeSplitRatio
    ToggleOpaque
    MoveCursorToCorner
    MoveCursor
    WorkspaceOption
    RenameWorkspace
    Exit
    ForceRendererReload
    MoveCurrentWorkspaceToMonitor
    MoveWorkspaceToMonitor
    SwapActiveWorkspaces
    BringActiveToTop
    ToggleSpecialWorkspace
    FocusUrgentOrLast
    ToggleSplit
    SwapWithMaster
    FocusMaster
    AddMaster
    RemoveMaster
    OrientationLeft
    OrientationRight
    OrientationTop
    OrientationBottom
    OrientationCenter
    OrientationPrev
    OrientationNext
    ToggleGroup
    ChangeGroupActive
    LockGroups
    MoveIntoGroup
    MoveOutOfGroup

  Corner* = enum
    TopRight = 0
    TopLeft = 1
    BottomRight = 2
    BottomLeft = 3

  LockType* = enum
    Lock
    Unlock
    ToggleLock

  DispatchType* = ref object
    case kind*: DispatchTypeKind
    of Custom:
      name*: string
      args*: string
    of SetCursor:
      theme*: string
      size*: uint16
    of Exec:
      program*: string
    of Pass:
      wident*: WindowIdentifier
    of Global:
      gString*: string
    of CloseWindow:
      cwIdent*: WindowIdentifier
    of Workspace:
      wIdentSpecial*: WorkspaceIdentifierWithSpecial
    of MoveToWorkspace, MoveToWorkspaceSilent:
      wmIdentSpecial*: WorkspaceIdentifierWithSpecial
      wmOptionalIdent*: Option[WindowIdentifier]
    of MoveFocusedWindowToWorkspace:
      fwIdent*: WorkspaceIdentifier
    of MoveFocusedWindowToWorkspaceSilent:
      wsIdent*: WorkspaceIdentifier
    of ToggleFloating:
      ofIdent*: Option[WindowIdentifier]
    of ToggleFullscreen:
      fsType*: FullscreenType
    of ToggleDPMS:
      dpBool1*: bool
      optStr*: Option[string]
    of MoveFocus:
      fDir*: Direction
    of MoveWindow:
      mv*: WindowMove
    of ResizeActive:
      rPos*: Position
    of MoveActive:
      mPos*: Position
    of ResizeWindowPixel:
      rwPos*: Position
      rwIdent*: WindowIdentifier
    of MoveWindowPixel:
      mwPos*: Position
      mwIdent*: WindowIdentifier
    of CycleWindow:
      cycleDir*: CycleDirection
    of SwapWindow:
      swapDir*: CycleDirection
    of FocusWindow:
      focwIdent*: WindowIdentifier
    of FocusMonitor:
      fmIdent*: MonitorIdentifier
    of ChangeSplitRatio:
      csFloat*: float32
    of MoveCursorToCorner:
      mcCorner*: Corner
    of MoveCursor:
      mx*: int64
      my*: int64
    of WorkspaceOption:
      wOpts*: WorkspaceOptions
    of RenameWorkspace:
      rwId*: int32
      owStr*: Option[string]
    of MoveCurrentWorkspaceToMonitor:
      mcwIdent*: MonitorIdentifier
    of MoveWorkspaceToMonitor:
      mwtIdent*: WorkspaceIdentifier
      mwtMonIdent*: MonitorIdentifier
    of SwapActiveWorkspaces:
      sawMonIdent*: MonitorIdentifier
      sawMonIdent2*: MonitorIdentifier
    of ToggleSpecialWorkspace:
      otsStr*: Option[string]
    of SwapWithMaster:
      swmParam*: SwapWithMasterParam
    of FocusMaster:
      fmParam*: FocusMasterParam
    of ChangeGroupActive:
      cgaSwitchDir*: WindowSwitchDirection
    of LockGroups:
      lgLockType*: LockType
    of MoveIntoGroup:
      gDir*: Direction
    else:
      discard

proc `$`*(wIdent: WorkspaceIdentifier): string {.inline.} =
  result =
    case wIdent.kind
    of wkWorkspaceId:
      fmt"{wIdent.wid}"
    of wkRelative:
      fmt"{wIdent.rInt}"
    of wkName:
      fmt"name:{wIdent.name}"
    of wkRelativeMonitor:
      fmt"{wIdent.rmInt}"
    of wkRelativeOpen:
      fmt"{wIdent.roInt}"
    of wkPrev:
      "previous"
    of wkEmpty:
      "empty"

proc `$`*(wIdent: WorkspaceIdentifierWithSpecial): string {.inline.} =
  result =
    case wIdent.kind
    of kWorkspaceId:
      fmt"{wIdent.wId}"
    of kRelative:
      fmt"{wIdent.rId}"
    of kRelativeMonitor:
      fmt"{wIdent.mId}"
    of kRelativeOpen:
      fmt"{wIdent.oId}"
    of kName:
      fmt"{wIdent.name}"
    of kSpecial:
      if wIdent.sName.isSome:
        fmt"special:{wIdent.sName.get()}"
      else:
        fmt"special"
    of kPrev:
      "previous"
    of kEmpty:
      "empty"

proc `$`*(opts: WorkspaceOptions): string {.inline.} =
  result =
    case opts
    of AllPseudo: "allpseudo"
    of AllFloat: "allfloat"

proc `$`*(sdir: WindowSwitchDirection): string {.inline.} =
  result =
    case sdir
    of Back: "b"
    of Forward: "f"

proc `$`*(cdir: CycleDirection): string {.inline.} =
  result =
    case cdir
    of Next: ""
    of Previous: "prev"

proc `$`*(dir: Direction): string {.inline.} =
  result =
    case dir
    of Up: "u"
    of Down: "d"
    of Left: "l"
    of Right: "r"

proc `$`*(ft: FullscreenType): string {.inline.} =
  result =
    case ft
    of Real: "0"
    of Maximize: "1"
    of NoParam: ""

proc `$`*(ident: WindowIdentifier): string {.inline.} =
  result =
    case ident.kind
    of kAddress:
      fmt"address:{ident.address}"
    of kClassRegex:
      fmt"{ident.expr}"
    of kProcessId:
      fmt"pid:{ident.pid}"
    of kTitle:
      fmt"title:{ident.title}"

proc `$`*(pos: Position): string {.inline.} =
  result =
    case pos.kind
    of kDelta:
      fmt"{pos.dx} {pos.dy}"
    of kExact:
      fmt"exact {pos.ex} {pos.ey}"

proc `$`*(ident: MonitorIdentifier): string {.inline.} =
  result =
    case ident.kind
    of ikDirection:
      $ident.direction
    of ikRelative:
      $ident.rId
    of ikId:
      $ident.id
    of ikName:
      ident.name
    of ikCurrent:
      "current"

proc genString*(cmd: DispatchType, dispatch: bool): string =
  let sep = if dispatch: " " else: ","
  case cmd.kind
  of Custom:
    result = fmt"{cmd.name}{sep}{cmd.args}"
  of Exec:
    result = fmt"exec{sep}{cmd.program}"
  of Pass:
    result = fmt"pass{sep}{cmd.wident}"
  of Global:
    result = fmt"global{sep}{cmd.gString}"
  of CloseWindow:
    result = fmt"closewindow{sep}{cmd.cwIdent}"
  of Workspace:
    result = fmt"workspace{sep}{cmd.wIdentSpecial}"
  of MoveToWorkspace:
    if cmd.wmOptionalIdent.isSome:
      result = fmt"movetoworkspace{sep}{cmd.wmIdentSpecial},{cmd.wmOptionalIdent.get()}"
    else:
      result = fmt"movetoworkspace{sep}{cmd.wmIdentSpecial}"
  of MoveToWorkspaceSilent:
    if cmd.wmOptionalIdent.isSome:
      result =
        fmt"movetoworkspacesilent{sep}{cmd.wmIdentSpecial},{cmd.wmOptionalIdent.get()}"
    else:
      result = fmt"movetoworkspacesilent{sep}{cmd.wmIdentSpecial}"
  of MoveFocusedWindowToWorkspace:
    result = fmt"workspace{sep}{cmd.fwIdent}"
  of MoveFocusedWindowToWorkspaceSilent:
    result = fmt"workspace{sep}{cmd.wsIdent}"
  of ToggleFloating:
    if cmd.ofIdent.isSome:
      result = fmt"togglefloating{sep}{cmd.ofIdent.get()}"
    else:
      result = fmt"togglefloating"
  of ToggleFullscreen:
    result = fmt"fullscreen{sep}{cmd.fsType}"
  of ToggleFakeFullscreen:
    result = fmt"fakefullscreen"
  of ToggleDPMS:
    if cmd.dpBool1:
      if cmd.optStr.isSome:
        result = fmt"dpms{sep}on{cmd.optStr.get()}"
      else:
        result = fmt"dpms{sep}on"
    else:
      if cmd.optStr.isSome:
        result = fmt"dpms{sep}off{cmd.optStr.get()}"
      else:
        result = fmt"dpms{sep}off"
  of TogglePseudo:
    result = "pseudo"
  of TogglePin:
    result = "pin"
  of MoveFocus:
    result = fmt"movefocus{sep}{cmd.fDir}"
  of MoveWindow:
    if cmd.mv.kind == mkDirection:
      result = fmt"movewindow{sep}{cmd.mv.direction}"
    else:
      result = fmt"movewindow{sep}{cmd.mv.monitor}"
  of CenterWindow:
    result = "centerwindow"
  of ResizeActive:
    result = fmt"resizeactive{sep}{cmd.rPos}"
  of MoveActive:
    result = fmt"moveactive{sep}{cmd.mPos}"
  of ResizeWindowPixel:
    result = fmt"movewindowpixel{sep}{cmd.rwPos},{cmd.rwIdent}"
  of MoveWindowPixel:
    result = fmt"movewindowpixel{sep}{cmd.mwPos},{cmd.mwIdent}"
  of CycleWindow:
    result = fmt"cyclenext{sep}{cmd.cycleDir}"
  of SwapWindow:
    result = fmt"focuswindow{sep}{cmd.swapDir}"
  of FocusWindow:
    result = fmt"swapnext{sep}{cmd.fwIdent}"
  of ChangeSplitRatio:
    result = fmt"splitratio {cmd.csFloat}"
  of ToggleOpaque:
    result = "toggleopaque"
  of MoveCursorToCorner:
    result = fmt"movecursor{sep}{cmd.mcCorner}"
  of MoveCursor:
    result = fmt"movecursor{sep}{cmd.mx} {cmd.my}"
  of WorkspaceOption:
    result = fmt"workspaceopt{sep}{cmd.wOpts}"
  of Exit:
    result = "exit"
  of ForceRendererReload:
    result = "forcerendererreload"
  of MoveWorkspaceToMonitor:
    result = fmt"moveworkspacetomonitor{sep}{cmd.mwtIdent} {cmd.mwtMonIdent}"
  of MoveCurrentWorkspaceToMonitor:
    result = fmt"movecurrentworkspacetomonitor{sep}{cmd.mcwIdent}"
  of ToggleSpecialWorkspace:
    if cmd.otsStr.isSome:
      result = fmt"togglespecialworkspace {cmd.otsStr.get()}"
    else:
      result = "togglespecialworkspace"
  of RenameWorkspace:
    if cmd.owStr.isSome:
      result = fmt"renameworkspace{sep}{cmd.rwId} {cmd.owStr.get()}"
    else:
      result = fmt"renameworkspace{sep}{cmd.rwId}"
  of SwapActiveWorkspaces:
    result = fmt"swapactiveworkspaces{sep}{cmd.sawMonIdent} {cmd.sawMonIdent2}"
  of BringActiveToTop:
    result = "bringactivetotop"
  of SetCursor:
    result = fmt"{cmd.theme} {cmd.size}"
  of FocusUrgentOrLast:
    result = "focusurgentorlast"
  of ToggleSplit:
    result = "togglesplit"
  of SwapWithMaster:
    result = fmt"swapwithmaster {cmd.swmParam}"
  of FocusMaster:
    result = fmt"focusmaster {cmd.fmParam}"
  of AddMaster:
    result = "addmaster"
  of RemoveMaster:
    result = "removemaster"
  of OrientationLeft:
    result = "orientationleft"
  of OrientationRight:
    result = "orientationright"
  of OrientationTop:
    result = "orientationtop"
  of OrientationBottom:
    result = "orientationbottom"
  of OrientationNext:
    result = "orientationnext"
  of OrientationPrev:
    result = "orientationprev"
  of ToggleGroup:
    result = "togglegroup"
  of ChangeGroupActive:
    result = fmt"changegroupactive{sep}{cmd.cgaSwitchDir}"
  of LockGroups:
    result = fmt"lockgroups{sep}{cmd.lgLockType}"
  of MoveIntoGroup:
    result = fmt"moveintogroup{sep}{cmd.gDir}"
  of MoveOutOfGroup:
    result = "moveoutofgroup"
  else:
    discard

proc `$`*(cmd: DispatchType): string {.inline.} =
  cmd.genString(true)

proc dispatch*(dispatchType: DispatchType) =
  let dispatchStr = "dispatch " & dispatchType.genString(true)

  let msg =
    writeToSocket(getSocketPath(kCommand), command(CommandKind.kEmpty, dispatchStr))

  if not msg.success:
    raise newException(
      HyprlandDefect, "dispatch command returned non-ok status: " & msg.response
    )
