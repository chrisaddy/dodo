import dodoparse
import db_sqlite
import terminaltables


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
    notes       TEXT,
    status      TEXT)"""))
  database.close()


proc save*(todo: Todo, databasePath: string): int64 =
  let database = open(databasePath, "", "", "")
  let id = database.insertId(
    sql"""INSERT INTO tasks (text, project, context, priority, created, notes, status)
          VALUES (?, ?, ?, ?, ?, ?, ?)""",
    todo.text,
    todo.project,
    todo.context,
    todo.priority,
    todo.timestamp,
    "notes:",
    "do"
  )

  return id

proc showTask*(databasePath: string, id: int): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks WHERE id = ?;", id):
    echo "task:       ", row[0]
    echo "status:     ", row[9]
    echo "project:    ", row[2]
    echo "context:    ", row[3]
    echo "priority:   ", row[4], "\n"
    echo  row[1], "\n"
    echo row[8]
        

proc showAll*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  for row in database.rows(sql"SELECT * FROM tasks;"):
    echo row

proc showDo*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  let tbl = newUnicodeTable()
  tbl.separateRows = true
  tbl.setHeaders(@["id", "project", "text", "context"])
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'do' ORDER BY priority, created DESC;"):
    tbl.addRow(@[row[0], row[2], row[1], row[3]])

  printTable(tbl)

proc showDoing*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  let tbl = newUnicodeTable()
  tbl.separateRows = true
  tbl.setHeaders(@["id", "project", "text", "context"])
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'doing' ORDER BY priority, started DESC;"):
    tbl.addRow(@[row[0], row[2], row[1], row[3]])

  printTable(tbl)


proc showDone*(databasePath: string): string =
  let database = open(databasePath, "", "", "")
  let tbl = newUnicodeTable()
  tbl.separateRows = true
  tbl.setHeaders(@["id", "project", "text", "context"])
  for row in database.rows(sql"SELECT * FROM tasks WHERE status = 'done' ORDER BY finished;"):
    tbl.addRow(@[row[0], row[2], row[1], row[3]])

  printTable(tbl)


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
  discard database.getRow(sql"UPDATE tasks SET text = ? WHERE id = ?;", newText, id)


proc addNote*(databasePath: string, id: int, text: string) =
  let database = open(databasePath, "", "", "")
  discard database.getRow(sql"UPDATE tasks SET notes = notes || ? WHERE id = ?;", text, id)


proc deleteTask*(databasePath: string, id: int): string =
  let database = open(databasePath, "", "", "")
  discard database.getRow(sql"DELETE FROM tasks WHERE id = ?", id)


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
