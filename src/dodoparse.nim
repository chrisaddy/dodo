import strutils
from times import getTime, toUnixFloat

type
  Todo* = object
    text*, project*, context*: string
    priority*: int
    timestamp*: float

proc parseDodo*(text: seq[string]): Todo =
  let ts = getTime().toUnixFloat()
  var project = ""
  var context: seq[string] = @[]
  var priority = 0

  for token in text:
    if token.startsWith('@'):
      project = token

    if token.startsWith('/'):
      context.add(token)

    if token == "+":
      priority = 1
    if token == "++":
      priority = 2
    if token == "+++":
      priority = 3
    if token == "++++":
      priority = 4


  return Todo(
    text : text.join(" "),
    project : project,
    context : context.join(","),
    priority : priority,
    timestamp: ts
  )
