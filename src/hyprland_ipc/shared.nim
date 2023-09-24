import std/[net, os, strformat], hexencoding

const BUF_SIZE* = 8192

type
  HyprlandDefect* = Defect
  CommandKind* = enum
    kJson
    kEmpty

  CommandContent* = ref object of RootObj
    kind*: CommandKind
    data*: string

  SocketKind* = enum
    kCommand
    kListener

  Address* = string

proc toSeq*(address: Address): seq[char] =
  decodeSeq(address)

proc getSocketPath*(kind: SocketKind): string =
  let hyprInstanceSig = getEnv("HYPRLAND_INSTANCE_SIGNATURE")

  let socketName = case kind:
    of kCommand:
      ".socket.sock"
    of kListener:
      ".socket2.sock"

  fmt"/tmp/hypr/{hyprInstanceSig}/{socketName}"

proc writeToSocket*(
  path: string,
  content: CommandContent
): tuple[success: bool, response: string] =
  let socket = newSocket(AF_UNIX, SOCK_STREAM, IPPROTO_IP)

  try:
    socket.connectUnix(path)
  except OSError:
    raise newException(HyprlandDefect, "Could not connect to Hyprland IPC UNIX path; is Hyprland running?")

  socket.send(content.data)

  var response = socket.recv(100)

  if response != "ok":
    return (success: false, response: response)
  
  return (success: true, response: "ok")

proc command*(kind: CommandKind, data: string): CommandContent =
  CommandContent(
    kind: kind,
    data: data
  )
