# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import os
import dodoparse
import typetraits
import dodostore
import flatdb



proc setup(): string =
  let db = "temp/test.db"
  if not dirExists("temp"):
    createDir("temp")
    writeFile(db, "")

  create(db)

  return db

proc tearDown() =
  removeDir("temp")


test "parse text input":
  var text = @["hello", "world"]
  var parsed = parseDodo(text)

  check: parsed.text == "hello world"
  check: parsed.project == ""
  check: parsed.context.len == 0
  check: parsed.priority == 0
  
  text = @["this", "is", "some", "longer", "text"]
  parsed = parseDodo(text)

  check: parsed.text == "this is some longer text"
  check: parsed.project == ""
  check: parsed.context.len == 0
  check: parsed.priority == 0

test "timestamp formatted correctly":
  var text = @["hello", "world"]
  var parsed = parseDodo(text)

  check: parsed.timestamp.type.name == "float"
  check: parsed.timestamp > 0.0


test "test setting priorities":
  var text = @["this", "is", "not", "important"]
  var parsed = parseDodo(text)

  check: parsed.priority == 0

  text = @["this", "is", "slightly", "important", "|"]
  parsed = parseDodo(text)

  check: parsed.priority == 1

  text = @["this", "is", "also", "|", "slightly", "important"]
  parsed = parseDodo(text)

  check: parsed.priority == 1

  text = @["this", "is", "slightly", "more", "important", "||"]
  parsed = parseDodo(text)

  check: parsed.priority == 2

  text = @["this", "is", "pretty", "important", "|||"]
  parsed = parseDodo(text)

  check: parsed.priority == 3

  text = @["this", "is", "verrrry", "important", "||||"]
  parsed = parseDodo(text)

  check: parsed.priority == 4


test "test adding project":
  var text = @["this", "is", "a", "verrrry", "important", "@work", "thing", "||||"]
  var parsed = parseDodo(text)

  check: parsed.priority == 4
  check: parsed.project == "@work"


  text = @["this", "is", "a", "verrrry", "important", "@@work", "thing", "||||"]
  parsed = parseDodo(text)

  check: parsed.priority == 4
  check: parsed.project == "@@work"


test "test adding context":
  var text = @["this", "needs", "#derek", "approval"]
  var parsed = parseDodo(text)

  check: parsed.context == "#derek"

test "test adding context, project, and priority":
  var text = @["this", "is", "#work", "@project", "that", "needs", "#derek", "approval", "|||"]
  var parsed = parseDodo(text)

  check: parsed.context == "#work,#derek"
  check: parsed.project == "@project"
  check: parsed.priority == 3

test "test storing new task":
  let db = setup()
  var text = @["this", "is", "#work", "@project", "that", "needs", "#derek", "approval", "|||"]
  var parsed = parseDodo(text)

  let saved = save(parsed, databasePath=db)
  check: saved == 1

  teardown()


test "retrieving open tasks":
  let db = setup()
  var text = @["this", "is", "#work", "@project", "that", "needs", "#derek", "approval", "|||"]
  var parsed = parseDodo(text)

  var saved = save(parsed, databasePath=db)
  check: saved == 1
  
  saved = save(parsed, databasePath=db)
  check: saved == 2

  saved = save(parsed, databasePath=db)
  check: saved == 3

  let open = showDo(db)
  check: open == 3

  teardown()

