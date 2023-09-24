import std/[strutils, strformat], shared, jsony

const
  HYPR_UNSET_FLOAT* = -340282346638528859811704183484516925440.0
  HYPR_UNSET_INT*   = -9223372036854775807

type
  OptionRaw* = ref object of RootObj
    option*: string
    intVal*: int
    floatVal*: float
    stringVal*: string

  OptionValueKind* = enum
    kInt
    kFloat
    kString

  OptionValue* = ref object of RootObj
    case kind*: OptionValueKind
    of kInt:
      intVal*: int
    of kFloat:
      floatVal*: float
    of kString:
      stringVal*: string

  Keyword* = ref object of RootObj
    option*: string
    value*: OptionValue

proc `$`*(value: OptionValue): string =
  case value.kind:
    of kInt:
      return intToStr(value.intVal)
    of kFloat:
      return $value.floatVal
    of kString:
      return value.stringVal

proc `$`*(keyword: Keyword): string =
  fmt"keyword {keyword.option} {keyword.value}"

proc setKeyword*(key: string, value: float | int | string) =
  when value is float:
    let msg = writeToSocket(
      getSocketPath(kCommand),
      command(
        kEmpty,
        $Keyword(option: key, value: OptionValue(kind: kFloat, floatVal: value))
      )
    )
    
    if not msg.success:
      raise newException(HyprlandDefect, "keyword set command returned non-ok status: " & msg.response)

  when value is int:
    let msg = writeToSocket(
      getSocketPath(kCommand),
      command(
        kEmpty,
        $Keyword(option: key, value: OptionValue(kind: kInt, intVal: value))
      )
    )

    if not msg.success:
      raise newException(HyprlandDefect, "keyword set command returned non-ok status: " & msg.response)

  when value is string:
    let msg = writeToSocket(
      getSocketPath(kCommand),
      command(
        kEmpty,
        $Keyword(option: key, value: OptionValue(kind: kString, stringVal: value))
      )
    )

    if not msg.success:
      raise newException(HyprlandDefect, "keyword set command returned non-ok status: " & msg.response)
