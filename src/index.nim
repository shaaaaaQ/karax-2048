import std/random
include karax / prelude

var board = @[
  @[2, 0, 0, 16],
  @[0, 4, 0, 0],
  @[0, 0, 0, 0],
  @[0, 0, 0, 8]
]

proc countEmptyTile(): int =
  result = 0
  for row in board:
    for value in row:
      if value == 0:
        inc(result)

proc addTile() =
  let emptyTileNum = countEmptyTile()
  if emptyTileNum != 0:
    let index = rand(1..emptyTileNum)
    var count = 0
    for y, row in board:
      for x, value in row:
        if value == 0:
          inc(count)
          if count == index:
            if rand(1..10) == 1:
              board[y][x] = 4
            else:
              board[y][x] = 2

proc moveLeft() =
  for y in countup(0, 3):
    for x in countup(0, 3):
      let value = board[y][x]
      if value == 0: continue
      var nx = x
      while true:
        dec(nx)
        if nx < 0: break
        elif board[y][nx] == 0:
          board[y][nx+1] = 0
          board[y][nx] = value
        elif board[y][nx] == value:
          board[y][nx+1] = 0
          board[y][nx] = value * 2
        else:
          break

proc moveDown() =
  for y in countdown(3, 0):
    for x in countup(0, 3):
      let value = board[y][x]
      if value == 0: continue
      var ny = y
      while true:
        echo "loop down"
        inc(ny)
        if ny > 3: break
        elif board[ny][x] == 0:
          board[ny-1][x] = 0
          board[ny][x] = value
        elif board[ny][x] == value:
          board[ny-1][x] = 0
          board[ny][x] = value * 2
        else:
          break

proc moveUp() =
  for y in countup(0, 3):
    for x in countup(0, 3):
      let value = board[y][x]
      if value == 0: continue
      var ny = y
      while true:
        echo "loop up"
        dec(ny)
        if ny < 0: break
        elif board[ny][x] == 0:
          board[ny+1][x] = 0
          board[ny][x] = value
        elif board[ny][x] == value:
          board[ny+1][x] = 0
          board[ny][x] = value * 2
        else:
          break

proc moveRight() =
  for y in countup(0, 3):
    for x in countdown(3, 0):
      let value = board[y][x]
      if value == 0: continue
      var nx = x
      while true:
        echo "loop right"
        inc(nx)
        if nx > 3: break
        elif board[y][nx] == 0:
          board[y][nx-1] = 0
          board[y][nx] = value
        elif board[y][nx] == value:
          board[y][nx-1] = 0
          board[y][nx] = value * 2
        else:
          break

proc renderTile(value: int): VNode =
  result = buildHtml(tdiv(class="w-[100px] h-[100px] text-center font-bold text-[30px] leading-[100px] bg-sky-200")):
    if value != 0:
      text($value)

proc renderBoard(): VNode =
  result = buildHtml(tdiv(class="w-fit grid grid-cols-4 gap-2")):
    for row in board:
      for value in row:
        renderTile(value)

proc renderController(): VNode =
  result = buildHtml(tdiv):
    button():
      text("←")
      proc onclick() =
        let tmp = board
        moveLeft()
        if tmp != board:
          addTile()
    button():
      text("↓")
      proc onclick() =
        moveDown()
    button():
      text("↑")
      proc onclick() =
        moveUp()
    button():
      text("→")
      proc onclick() =
        moveRight()

proc createDom(): VNode =
  result = buildHtml(tdiv):
    renderBoard()
    renderController()

setRenderer(createDom)