import dodoparse
import dodostore
import os


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
  if text.len == 0:
    raise EmptyTask.newException("task must not be empty")
  let todo = parseDodo(text)

  let id = save(todo, db)
  echo "task ", id, " added."

  return todo

proc move*(args: seq[string]): string =
  moveTask(db, id=args[0], destination=args[1])
  echo "moved task ", args[0], " to ", args[1]

proc show*(status = "open"): string =
  case status:
    of "open":
      return showOpen(db)
    of "doing":
      return showDoing(db)
    of "done":
      return showDone(db)
    of "all":
      return showAll(db)
    else: discard
  discard
  # show(database)

when isMainModule:
  import cligen
  dispatchMulti([dodo.add], [show], [dodo.move])
