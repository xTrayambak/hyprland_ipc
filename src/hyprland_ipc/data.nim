import jsony, shared, strformat

type
  DataCommands* = enum
    Monitors
    AllMonitors
    Workspaces
    ActiveWorkspace
    Clients
    ActiveWindow
    Layers # TBD
    Devices  # TBD
    Version
    CursorPosition
    Binds # TBD
    Animations # TBD
    ConfigErrors # Probably not that useful
    Decorations # Probably not that useful
    GetOption # TBD
    GlobalShortcuts # TBD
    Instances # Probably not that useful
    Layouts # Probably not that useful
    Splash # Probably not that useful
    SystemInfo # Probably not that useful
    WorkspaceRules # TBD

  BasicWorkspaceInfo* = object # This is only for the deserialization of the monitor object
    id*: int
    name*: string

  Vector2D* = tuple
    x, y: int

  Rectangle = tuple
    x, y, w, h: int

  HyprlandVersion* = object
    branch*, commit*: string
    dirty: bool
    commit_message*, commit_date*, tag*: string
    commits*: int
    # TODO: Missing an array called flags, whatever that is. Probably not important

  Client* = object
    address*: Address # Hex string of 48-bit unsigned int
    mapped*, hidden*: bool
    at*, size*: Vector2D
    floating*: bool
    monitor*: int
    class*, title*, initialClass*, initialTitle*: string
    pid*: int
    xwayland*, pinned*, fullscreen*: bool
    fullscreenMode*: int # TODO: Find out what this int means and make it an enum
    fakeFullscreen*: bool
    grouped*: seq[string] # List of address hex strings that this window is grouped with
    swallowing*: string # This seems to be an address of the swallowed window or 0x0 when not swallowing
    focusHistoryID*: int

  Workspace* = object
    id*: int
    name*, monitor*: string
    monitorID*, windows*: int
    hasfullscreen*: bool
    lastwindow*: Address
    lastwindowtitle*: string

  Monitor* = object
    id*: int
    name*, description*, make*, model*, serial*: string
    width*, height*: int
    refreshRate*: float
    x*, y*: int
    activeWorkspace*, specialWorkspace*: BasicWorkspaceInfo
    reserved*: Rectangle
    scale*: float
    transform: int
    focused*, dpmsStatus*, vrr*, activelyTearing*, disabled*: bool
    currentFormat*: string
    availableModes*: seq[string]

proc `$`*(cmd: DataCommands): string =
  result = case cmd
  of Monitors: "monitors"
  of AllMonitors: "monitors all"
  of Workspaces: "workspaces"
  of ActiveWorkspace: "activeworkspace"
  of Clients: "clients"
  of ActiveWindow: "activewindow"
  of Layers: "layers"
  of Devices: "devices"
  of Version: "version"
  of CursorPosition: "cursorposition"
  of Binds: "binds"
  of Animations: "animations"
  else: "NOT IMPLEMENTED" # TODO: Add strings even for commands without parsing implemented

proc getDataCmdJson(cmd: DataCommands): string =
  let dataCmdString = fmt"j/{cmd}"

  let msg = sendJsonRequest(
    getSocketPath(kCommand),
    command(kJson, dataCmdString)
  )

  if not msg.success:
    raise newException(HyprlandDefect, fmt"{cmd} command returned non-ok status: {msg.response}")
  else:
    return msg.response

proc getDataAsObj[T](dataCmd: DataCommands): T =
  let reply = getDataCmdJson(dataCmd)
  return fromJson[T](reply, typedesc[T])

proc getClients*(): seq[Client] = getDataAsObj[seq[Client]](Clients)
proc getActiveWindow*(): Client = getDataAsObj[Client](ActiveWindow)
proc getWorkspaces*(): seq[Workspace] = getDataAsObj[seq[Workspace]](Workspaces)
proc getActiveWorkspace*(): Workspace = getDataAsObj[Workspace](ActiveWorkspace)
proc getCursorPosition*(): Vector2D = getDataAsObj[Vector2D](CursorPosition)
proc getVersion*(): HyprlandVersion = getDataAsObj[HyprlandVersion](Version)
proc getMonitors*(): seq[Monitor] = getDataAsObj[seq[Monitor]](Monitors)
proc getAllMonitors*(): seq[Monitor] = getDataAsObj[seq[Monitor]](AllMonitors)
