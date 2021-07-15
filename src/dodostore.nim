import dodoparse
import db_sqlite
import terminal

proc print(text: string, color: ForegroundColor): string =
  setForegroundColor(color)
  stdout.write(text)
  resetAttributes()

proc print(text: Row, color: ForegroundColor): string =
  setForegroundColor(color)
  stdout.write(text)
  resetAttributes()

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

proc deleteTask*(databasePath: string, id: int): string =
  let database = open(databasePath, "", "", "")
  discard database.getRow(sql"DELETE FROM tasks WHERE id = ?", id)


proc showAll*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks;"):
    echo row[0], " ", row[2], " ", row[3]
    if row[4] == "4":
      discard print(row[1], fgRed)
    if row[4] == "3":
      discard print(row[1], fgYellow)
    if row[4] in @["0", "1", "2"]:
      discard print(row[1], fgGreen)
    echo "\n"

proc showDo*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'do';"):
    echo row[0], " ", row[2], " ", row[3]
    if row[4] == "4":
      discard print(row[1], fgRed)
    if row[4] == "3":
      discard print(row[1], fgYellow)
    if row[4] in @["0", "1", "2"]:
      discard print(row[1], fgGreen)
    echo "\n"




proc showDoing*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'doing';"):
    echo row[0], " ", row[2], " ", row[3]
    if row[4] == "4":
      discard print(row[1], fgRed)
    if row[4] == "3":
      discard print(row[1], fgYellow)
    if row[4] in @["0", "1", "2"]:
      discard print(row[1], fgGreen)
    echo "\n"


proc showDone*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'done';"):
    echo row[0], " ", row[2], " ", row[3]
    discard print(row[1], fgCyan)
    echo "\n"

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
