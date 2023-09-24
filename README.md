# Hyprland_nim
---
An unofficial Nim wrapper for Hyprland's IPC

# Disclaimer
A few dispatch commands haven't been binded yet and this has only been tested with the latest version of Hyprland as of 20/9/2023.

A few API names have to be fixed to maintain parity.

# Getting started!
Let's get started with Hyprland_nim!

## Adding to your project
Add the code below to the dependencies section of your <project name>.nimble file!
```
requires "https://github.com/xTrayambak/hyprland_ipc"
```

# What this library provides
- `ctl` for controlling the compositor
- `dispatch` for issuing dispatch commands
- `keyword` for keywords (eg. `decoration:blur:enable`)

# What is incomplete
- `data` for getting information on the compositor
- some dispatch commands in `dispatch`

Keep in mind that the dispatch command list is huge and hasn't been thoroughly tested. Please report issues.

# Examples
Check `examples/` for example code
