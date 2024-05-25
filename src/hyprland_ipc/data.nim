import jsony, shared, strformat

type
  DataCommands* = enum
    Monitors
    Workspaces
    ActiveWorkspace
    Clients
    ActiveWindow
    Layers
    Devices
    Version
    CursorPosition
    Binds
    Animations

  WorkspaceBasic* = ref object
    id*: uint32

  Client* = object
    address*: Address # Hex string of 48-bit unsigned int
    mapped*, hidden*: bool
    at*, size*: tuple[x, y: int]
    floating*: bool
    monitor*: int
    class*, title*, initialClass*, initialTitle*: string
    pid*: int
    xwayland*, pinned*, fullscreen*: bool
    fullscreenMode*: int # TODO: Find out what this int means and make it an enum
    fakeFullscreen*: bool
    grouped*: seq[string] # List of address hex strings that this window is grouped with
    swallowing*: string # TODO: Probably an address of the swallowed window or 0x0 when not swallowing
    focusHistoryID*: int

proc `$`*(cmd: DataCommands): string =
  result = case cmd
  of Monitors: "monitors"
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

proc hyprctlClients*(): seq[Client] =
  let reply = getDataCmdJson(Clients)
  return fromJson(reply, seq[Client])
