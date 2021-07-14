import dodoparse
import db_sqlite


# Create table

proc create*(databasePath: string) =
  let database = open(databasePath, "", "", "")
  database.exec(sql"DROP TABLE IF EXISTS tasks")
  database.exec(sql("""CREATE TABLE tasks (
    id          INTEGER PRIMARY KEY,
    text        TEXT,
    project     TEXT,
    context     TEXT,
    priority    INTEGER,
    created     REAL,
    started     REAL,
    finished    REAL,
    status      TEXT)"""))
  database.close()


proc save*(todo: Todo, databasePath: string): int64 =
  let database = open(databasePath, "", "", "")
  let id = database.insertId(
    sql"""INSERT INTO tasks (text, project, context, priority, created, status)
          VALUES (?, ?, ?, ?, ?, ?)""",
    todo.text,
    todo.project,
    todo.context,
    todo.priority,
    todo.timestamp,
    "do"
  )

  return id


proc showAll*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks;"):
    echo row

proc showDo*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'do';"):
    echo row

proc showDoing*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'doing';"):
    echo row

proc showDone*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'done';"):
    echo row


proc showTaskText*(databasePath: string, id: int): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT text FROM tasks WHERE id = ?;", id):
    echo row

proc showProjects*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT project, COUNT(project) as unfinished FROM tasks WHERE status != 'done' GROUP BY project;;"):
    echo row


proc editTaskText*(databasePath: string, id: int, newText: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"UPDATE tasks SET text = ? WHERE id = ?;", newText, id):
    discard row


proc moveTask*(databasePath: string, id: string, destination: string, timestamp: float) =
  let database = open(databasePath, "", "", "")
  discard database.getRow(sql"UPDATE tasks SET status = ? WHERE id = ?", destination, id)
  discard database.getRow(sql"UPDATE tasks SET status = ? WHERE id = ?", destination, id)

  case destination:
    of "doing":
      discard database.getRow(sql"UPDATE tasks SET started = ? WHERE id = ?", timestamp, id)
    of "done":
      discard database.getRow(sql"UPDATE tasks SET finished = ? WHERE id = ?", timestamp, id)
    else: discard
