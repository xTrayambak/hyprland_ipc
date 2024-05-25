import std/[strutils, strformat], shared, dispatch, keyword

type
  Mod* = enum
    mSuper
    mShift
    mAlt
    mCtrl
    mNone

  Key* = ref object
    mods*: seq[Mod]
    key*: string

  Flag* = enum
    fL
    fM
    fE
    fR

  Binding* = ref object
    mods*: seq[Mod]
    key*: Key
    flags*: seq[Flag]
    dispatcher*: DispatchType

proc `$`*(flag: Flag): string =
  result = case flag
  of fL: "l"
  of fM: "m"
  of fE: "e"
  of fR: "r"

proc `$`*(`mod`: Mod): string =
  result = case `mod`
  of mSuper: "SUPER"
  of mShift: "SHIFT"
  of mAlt: "ALT"
  of mCtrl: "CTRL"
  of mNone: ""

proc `$`*(key: Key): string =
  if key.mods.len > 0:
    result = fmt"{key.mods.join()}_{key.key}"
  else:
    result = fmt"{key.key}"

proc `$`*(mods: seq[Mod]): string =
  for i, `mod` in mods:
    result &= $`mod`

    if i < mods.len-1:
      result &= '_'
  
proc genStr*(binding: Binding): string =
  fmt"{binding.mods},{binding.key},{binding.dispatcher}"

proc key*(key: string, mods: seq[Mod] = @[]): Key =
  Key(
    key: key,
    mods: mods
  )

proc commit*(binding: Binding) =
  setKeyword(
    fmt"bind {binding.flags.join()}",
    genStr(binding)
  )

proc bindKey*(
  mods: seq[Mod],
  key: Key,
  dispatch: DispatchType
) =
  let binding = Binding(
    mods: mods,
    key: key,
    flags: @[],
    dispatcher: dispatch
  )
  echo genStr(binding)

  binding.commit()
