# Package

version       = "0.1.0"
author        = "sh"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
binDir        = "public"
bin           = @["index"]
backend       = "js"


# Dependencies

requires "nim >= 2.0.0"
requires "karax"
requires "jsony"
