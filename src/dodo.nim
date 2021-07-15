import dodoparse
import dodostore
import os
import times

const homeDir = getHomeDir()
var taskDir = homeDir & ".dodo"
var db = taskDir & "/task.db"

if not fileExists(db):
  echo "creating task db at ", db
  if not dirExists(taskDir):
    createDir(taskDir)
  writeFile(db, "")
  create(db)


type EmptyTask* = object of ValueError
proc add(text: seq[string]): Todo =
  if text.len == 0 or text.len == 1 and text[0] == "":
    raise EmptyTask.newException("task must not be empty")
  let todo = parseDodo(text)

  let id = save(todo, db)
  echo "task ", id, " added."

proc edit*(ids: seq[int]): string =
  for id in ids:
    echo "task ", id, " old text:"
    discard showTaskText(db, id)
    echo "task ", id, " new text:"
    let newText = readLine(stdin)
    discard editTaskText(db, id, newText)
    echo "task ", id, " updated"

  

proc move*(args: seq[string]): string =
  let ts = getTime().toUnixFloat()
  moveTask(db, id=args[0], destination=args[1], timestamp=ts)
  if args[1] == "doing":
    echo "moved task ", args[0], " to ", args[1], " and started task timer"
  else:
    echo "moved task ", args[0], " to ", args[1]

proc start*(tasks: seq[string]): string =
  for task in tasks:
    discard move(@[task, "doing"])


proc doing*(): string =
  return showDoing(db)

proc todo*(): string =
  return showDo(db)

proc done*(): string =
  return showDone(db)

proc projects*(): string =
  return showProjects(db)

proc show*(status = "open"): string =
  case status:
    of "open":
      return showDo(db)
    of "doing":
      return showDoing(db)
    of "done":
      return showDone(db)
    of "all":
      return showAll(db)
    else: discard
  discard

proc delete*(ids: seq[int]): string =
  for id in ids:
    discard deleteTask(db, id=id)
    echo "task ", id, " deleted"

when isMainModule:
  import cligen

  dispatchMulti(
    [dodo.add, help={"text": "todo text:\n\t@ at the beginning of a word assigns it to a project.\n\t\tExample: 'this is a @work project'\n\t# at the beginning of a word assigns it to a context.\n\t\tExample: 'this task has #home and #weekend contexts'\n\t|, ||, |||, |||| assigns priorities 1, 2, 3, 4, respectively.\n\t\tExample: 'This is a pretty important task |||'"}],
    [todo],
    [dodo.delete],
    [doing],
    [done],
    [edit],
    [dodo.move],
    [projects],
    [show],
    [start]
  )
