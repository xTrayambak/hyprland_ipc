import std/[net, os, strformat, strutils]
import hexencoding

const BUF_SIZE* = 8192

type
  HyprlandDefect* = Defect
  CommandKind* = enum
    kJson
    kEmpty

  CommandContent* = object
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

  when not defined(useOldIpcPath):
    let runtimeDir = getEnv("XDG_RUNTIME_DIR", "/run/user/1000")
    result = fmt"{runtimeDir}/hypr/{hyprInstanceSig}/{socketName}"
  else:
    result = fmt"/tmp/hypr/{hyprInstanceSig}/{socketName}"

proc sendRequestAndReadReply(path: string, content: CommandContent): string =
  let socket = newSocket(AF_UNIX, SOCK_STREAM, IPPROTO_IP)
  defer: close socket

  try:
    socket.connectUnix(path)
  except OSError:
    raise newException(HyprlandDefect, "Could not connect to Hyprland IPC UNIX path; is Hyprland running?")

  socket.send(content.data)

  var response: string
  var bytesRead = 8192
  while bytesRead == 8192:
    bytesRead = socket.recv(response, BUF_SIZE)
    result.add response

proc writeToSocket*(
  path: string,
  content: CommandContent
): tuple[success: bool, response: string] =
  let response = sendRequestAndReadReply(path, content)
  return (response == "ok", response)

proc sendJsonRequest*(
  path: string,
  content: CommandContent
): tuple[success: bool, response: string] =

  let response = sendRequestAndReadReply(path, content)
  # On success Json commands will return json (that starts with the below chars), anything else is an error string
  return (response[0] in {'\"', '{', '['}, response) 

proc command*(kind: CommandKind, data: string): CommandContent =
  CommandContent(
    kind: kind,
    data: data
  )
