import pkg/[jsony]
import ./shared

type DataCommands* = enum
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

proc `$`*(cmd: DataCommands): string =
  result =
    case cmd
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

proc callHyprctlDataCmd*(cmd: DataCommands) =
  let msg = writeToSocket(getSocketPath(kCommand), command(kJson, cmd.toJson()))

type WorkspaceBasic* = ref object
  id*: uint32
