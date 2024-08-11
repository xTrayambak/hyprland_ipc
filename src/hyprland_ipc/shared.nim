import std/[net, os, strformat, strutils]
import hexencoding

const BUF_SIZE* = 8192

type
  ## Raised when the client cannot connect to a running Hyprland IPC instance.
  IPCConnectionError* = object of CatchableError

  ## Raised when the server returns a response that isn't successful.
  CommandError* = object of CatchableError

  CommandKind* = enum
    ## The command type that we're sending to the IPC server.
    ## `kJson`  - the command content is a JSON payload
    ## `kEmpty` - the command content is plaintext data
    kJson
    kEmpty

  CommandContent* = object
    ## The content of a command, along with the data kind (JSON or empty)
    kind*: CommandKind
    data*: string

  SocketKind* = enum
    ## The kind of socket that we want to connect to
    ## `kCommand`  - a command dispatcher
    ## `kListener` - an event listener
    kCommand
    kListener

  Address* = string

proc toSeq*(address: Address): seq[char] {.inline.} =
  decodeSeq(address)

proc getSocketPath*(kind: SocketKind): string =
  ## Fetch the IPC socket path of the currently running Hyprland instance.
  let hyprInstanceSig = getEnv("HYPRLAND_INSTANCE_SIGNATURE")

  let socketName =
    case kind
    of kCommand: ".socket.sock"
    of kListener: ".socket2.sock"

  when not defined(hyprlandUseOldIpcPath):
    let runtimeDir = getEnv("XDG_RUNTIME_DIR", "/run/user/1000")
    fmt"{runtimeDir}/hypr/{hyprInstanceSig}/{socketName}"
  else:
    fmt"/tmp/hypr/{hyprInstanceSig}/{socketName}"

proc sendRequestAndReadReply(path: string, content: CommandContent): string =
  ## Send some data to the Hyprland IPC socket(s).
  ## This function connects to the socket path provided, granted that it is a valid Hyprland IPC server and sends some data to it.
  ## 
  ## If successful, this function returns a tuple with the `success` field set to `true`. Otherwise,
  ## it returns with `success` set to false and the `response` field contains the error provided by the Hyprland instance.
  let socket = newSocket(AF_UNIX, SOCK_STREAM, IPPROTO_IP)
  defer: close socket

  try:
    socket.connectUnix(path)
  except OSError as exc:
    raise newException(
      IPCConnectionError,
      "Could not connect to Hyprland IPC UNIX socket path; is Hyprland running? (" &
        exc.msg & ": " & path & ')',
    )

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
  ## Construct a command with  
  CommandContent(kind: kind, data: data)
