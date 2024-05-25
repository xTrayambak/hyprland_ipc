# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "A Nim interface for the Hyprland IPC"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.14"
requires "jsony >= 1.1.5"
taskRequires "fmt", "nph >= 0.5.1"

task fmt, "Format code":
  exec "nph src/"
