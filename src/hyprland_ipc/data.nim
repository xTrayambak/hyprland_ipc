import std/[strformat, tables]
import pkg/jsony
import ./shared

type
  DataCmdKind* = enum
    Monitors = "monitors"
    Workspaces = "workspaces"
    ActiveWorkspace = "activeworkspace"
    Clients = "clients"
    ActiveWindow = "activewindow"
    Layers = "layers"
    Devices = "devices"
    Version = "version"
    CursorPosition = "cursorposition"
    Binds = "binds"
    Animations = "animations"
    ConfigErrors = "configerrors" # Probably not that useful
    Decorations = "decorations" # Probably not that useful
    GetOption = "getoption" # Getting the actual option value is not implemented yet
    GlobalShortcuts = "globalshortcuts" # Could be useful when apps actually start using the shortcuts xdg portal
    Instances = "instances" # Probably not that useful
    Layouts = "layouts"
    Splash = "splash" # Probably not that useful
    SystemInfo = "systeminfo" # Probably not that useful
    WorkspaceRules = "workspacerules"

  DataCommand* = object
    case kind*: DataCmdKind
    of GetOption:
      name: string
    of Monitors:
      all: bool # Includes disabled monitors
    else:
      discard

  BasicWorkspaceInfo* = object # This is only for the deserialization of the monitor object
    id*: int
    name*: string

  Vector2D* = tuple
    x, y: int

  Rectangle* = tuple
    x, y, w, h: int

  HyprlandVersion* = object
    branch*, commit*: string
    dirty: bool
    commit_message*, commit_date*, tag*: string
    commits*: int
    # TODO: Missing an array called flags, whatever that is. Probably not important.

  # TODO: Many objects in this section could benefit from using Option types, because many hyprctl commands return json
  # that doesn't have all the fields in it (e.g. workspacerules). Some types could also use existing types from dispatch.nim.
  Client* = object
    address*: Address # Hex string of 48-bit unsigned int
    mapped*, hidden*: bool
    at*, size*: Vector2D
    floating*: bool
    monitor*: int
    class*, title*, initialClass*, initialTitle*: string
    pid*: int
    xwayland*, pinned*: bool
    fullscreen*: int
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

  LayerEnum* = enum # Enum for future use with LayersOnMonitor
    Background # Wallpaper
    Bottom # Normal app windows are between Bottom and Tap (but idk what uses Bottom)
    Top # Bars and desktop ui (drawn on top of normal apps)
    Overlay # Probably drawn on top of the entire monitor framebuffer

  WindowOnLayer* = object # This object represents a window and its dimensions
    address*: Address
    x*, y*, w*, h*: int
    namespace*: string
  # TODO: Currently this matches the json structure given by the layers command, but the structure is a bit hard
  # to work with. The structure could be changed to layersOnMonitor[monitor][layerEnum], where layerEnum is
  LayersOnMonitor* = Table[string, # Monitor name
                     Table[string, # Levels key
                     Table[string, # Level number (int as string)
                           seq[WindowOnLayer]]]] # Actual layer (seq because multiple windows can occupy the same layer)

  Mouse* = object
    address*: Address
    name*: string
    defaultSpeed*: float

  Keyboard* = object
    address*: Address
    name*, rules*, model*, layout*, variant*, options*, active_keymap*: string
    main*: bool

  DeviceList* = object
    mice*: seq[Mouse]
    keyboards*: seq[Keyboard]
    # TODO: Missing tablets and touch (touchscreens) fields
  
  Option* = object
    option*: string
    # TODO: Add <typeName>: value field. Requires custom parsing, because there are many types
    set*: bool

  Bind* = object
    locked*, mouse*, release*, repeat*, nonConsuming*: bool
    modmask*: int # Proper representation for this would be a set[modEnum] where modEnum contains the mod keys
    submap*, key*: string
    keycode*: int # Idk what this is and why its 0 for all my binds
    catchAll*: bool
    dispatcher*, arg*: string

  Animation* = object
    name*: string
    overridden*: bool
    bezier*: string
    enabled*: bool
    speed*: float
    style*: string

  WorkspaceRule* = object
    # TODO: Parse workspaceStrings into WorkspaceIdentifier using for example nitely/nim-regex
    workspaceString*, monitor*: string 
    default*: bool
    gapsIn*, gapsOut*, borderSize*: int
    border*, shadow*, rounding*, decorate*, persistent*: bool
    onCreatedEmpty*, defaultName*: string

proc `$`*(cmd: DataCommand): string =
  case cmd.kind
  # Commands with arguments
  of GetOption: result = fmt"getoption {cmd.name}"
  of Monitors:
    result = $cmd.kind
    if cmd.all: result &= " all"
  # Commands without arguments
  else: result = $cmd.kind

proc getDataCmdJson(cmd: DataCommand): string =
  let dataCmdString = fmt"j/{cmd}"

  let msg = sendJsonRequest(getSocketPath(kCommand), command(kJson, dataCmdString))

  if not msg.success:
    raise newException(CommandError, fmt"{cmd} command returned non-ok status: {msg.response}")
  else:
    return msg.response

proc getDataAsObj[T](dataCmd: DataCommand): T =
  let reply = getDataCmdJson(dataCmd)
  return fromJson[T](reply, typedesc[T])

proc getClients*(): seq[Client] = getDataAsObj[seq[Client]] DataCommand(kind: Clients)
proc getActiveWindow*(): Client = getDataAsObj[Client] DataCommand(kind: ActiveWindow)
proc getWorkspaces*(): seq[Workspace] = getDataAsObj[seq[Workspace]] DataCommand(kind: Workspaces)
proc getActiveWorkspace*(): Workspace = getDataAsObj[Workspace] DataCommand(kind: ActiveWorkspace)
proc getCursorPosition*(): Vector2D = getDataAsObj[Vector2D] DataCommand(kind: CursorPosition)
proc getVersion*(): HyprlandVersion = getDataAsObj[HyprlandVersion] DataCommand(kind: Version)
proc getMonitors*(all: bool): seq[Monitor] = getDataAsObj[seq[Monitor]] DataCommand(kind: Monitors)
proc getLayers*(): LayersOnMonitor = getDataAsObj[LayersOnMonitor] DataCommand(kind: Layers)
proc getDevices*(): DeviceList = getDataAsObj[DeviceList] DataCommand(kind: Devices)
proc getOption*(option: string): Option = getDataAsObj[Option] DataCommand(kind: GetOption, name: option)
proc getBinds*(): seq[Bind] = getDataAsObj[seq[Bind]] DataCommand(kind: Binds)
proc getAnimations*(): seq[Animation] = getDataAsObj[seq[Animation]] DataCommand(kind: Animations)
proc getWorkspaceRules*(): seq[WorkspaceRule] = getDataAsObj[seq[WorkspaceRule]] DataCommand(kind: WorkspaceRules)
proc getLayouts*(): seq[string] = getDataAsObj[seq[string]] DataCommand(kind: Layouts)
