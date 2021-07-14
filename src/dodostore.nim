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
    timestamp   REAL,
    status      TEXT)"""))
  database.close()


proc save*(todo: Todo, databasePath: string): int64 =
  let database = open(databasePath, "", "", "")
  let id = database.insertId(
    sql"""INSERT INTO tasks (text, project, context, priority, timestamp, status)
          VALUES (?, ?, ?, ?, ?, ?)""",
    todo.text,
    todo.project,
    todo.context,
    todo.priority,
    todo.timestamp,
    "open"
  )

  return id


proc showAll*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks;"):
    echo row

proc showOpen*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'open';"):
    echo row

proc showDoing*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'doing';"):
    echo row

proc showDone*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'done';"):
    echo row


proc moveTask*(databasePath: string, id: string, destination: string) =
  let database = open(databasePath, "", "", "")
  discard database.getRow(sql"UPDATE tasks SET status = ? WHERE id = ?", destination, id)
