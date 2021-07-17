# Package

version       = "0.1.0"
author        = "chrisaddy"
description   = "todo list manager"
license       = "MIT"
srcDir        = "src"
bin           = @["dodo"]


# Dependencies

requires "nim >= 1.4.8", "cligen >= 1.5.5.", "terminaltables >= 0.1.1"
