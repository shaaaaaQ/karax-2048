import std/random, std/tables, std/strformat
include karax / prelude
import karax / kdom
import karax / localstorage
import jsony

type Direction = enum
  Left
  Down
  Up
  Right

type Board = seq[seq[int]]

var
  board: Board
  score: int
  isGameOver: bool

proc store() =
  setItem("k2048::board", board.toJson().cstring)
  setItem("k2048::score", ($score).cstring)

proc getDirection(dir: Direction): tuple[x: int, y: int] =
  case dir
  of Left: result = (x: -1, y: 0)
  of Down: result = (x: 0, y: 1)
  of Up: result = (x: 0, y: -1)
  of Right: result = (x: 1, y: 0)


proc canMove(board: Board): bool =
  result = false
  for y, row in board:
    for x, value in row:
      if value == 0:
        # 空
        result = true
      if x < 3 and board[y][x+1] == value:
        # 右
        result = true
      if y < 3 and board[y+1][x] == value:
        # 下
        result = true


proc countEmptyTile(board: Board): int =
  result = 0
  for row in board:
    for value in row:
      if value == 0:
        inc(result)

proc addTile(board: var Board) =
  let emptyTileNum = board.countEmptyTile()
  if emptyTileNum != 0:
    randomize()
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

proc newBoard() =
  score = 0
  isGameOver = false
  board = @[
    @[0, 0, 0, 0],
    @[0, 0, 0, 0],
    @[0, 0, 0, 0],
    @[0, 0, 0, 0]
  ]
  board.addTile()
  store()

proc move(board: var Board, dir: Direction) =
  var moved = false
  var lock: seq[seq[int]]

  let (dirX, dirY) = getDirection(dir)

  for y in (if dirY < 0: [0, 1, 2, 3] else: [3, 2, 1, 0]):
    for x in (if dirX < 0: [0, 1, 2, 3] else: [3, 2, 1, 0]):
      let value = board[y][x]
      if value == 0: continue

      var nx = x
      var ny = y

      while true:
        nx += dirX
        ny += dirY

        if nx < 0 or nx > 3 or ny < 0 or ny > 3: break

        if board[ny][nx] == 0:
          board[ny][nx] = value
          board[ny-dirY][nx-dirX] = 0
          moved = true
        elif board[ny][nx] == value:
          if lock.contains(@[nx, ny]) == false:
            board[ny-dirY][nx-dirX] = 0
            board[ny][nx] = value * 2
            lock.add(@[nx, ny])
            score += value * 2
            moved = true
        else:
          break

  if moved:
    board.addTile()

  isGameOver = not board.canMove()

  store()

proc renderTile(value: int): VNode =
  result = buildHtml(tdiv(class=fmt("text-center font-bold text-[30px] leading-[100px] bg-[darkslategray] text-[whitesmoke] tile-{value}"))):
    text($value)

proc renderCell(): VNode =
  result = buildHtml(tdiv(class="w-[100px] h-[100px] bg-gray-500"))

proc renderBoard(): VNode =
  result = buildHtml(tdiv(class="w-fit h-fit my-10 relative")):
    tdiv(class="grid grid-cols-4 gap-2"):
      for row in board:
        for value in row:
          renderCell():
            if value != 0:
              renderTile(value)

    if isGameOver:
      tdiv(class="bg-gray-400/70 w-full h-full absolute top-0 left-0 flex animate-fade-in"):
        tdiv(class="font-bold text-6xl m-auto"):
          text("GameOver")

proc renderScore(): VNode =
  result = buildHtml(tdiv(class="w-full p-3 bg-sky-700 text-sky-100 rounded-md text-end")):
    text($score)

proc renderNewButton(): VNode =
  result = buildHtml(button(class="p-3 bg-sky-700 text-sky-100 rounded-md hover:bg-sky-600 transition-colors")):
    text("New")
    proc onclick() =
      newBoard()

proc createDom(): VNode =
  result = buildHtml(tdiv(class="w-fit mx-auto my-10 select-none")):
    tdiv(class="flex gap-3"):
      renderScore()
      renderNewButton()
    renderBoard()
    tdiv(class="[&>a]:text-blue-700 select-text"):
      text("キーボードの矢印キーで動かせる")
      br()
      a(href="https://github.com/karaxnim/karax"):
        text("Karax")
      br()
      a(href="https://github.com/shaaaaaQ/karax-2048"):
        text("GitHub")

proc onkeydown(ev: dom.Event) =
  let ev = KeyboardEvent(ev)
  case ev.key
  of "h", "ArrowLeft", "a":
    board.move(Left)
  of "j", "ArrowDown", "s":
    board.move(Down)
  of "k", "ArrowUp", "w":
    board.move(Up)
  of "l", "ArrowRight", "d":
    board.move(Right)
  redraw(kxi)

var dragStartPos = toTable({"x": 0, "y": 0})

proc onmousedown(ev: dom.Event) =
  let ev = MouseEvent(ev)
  dragStartPos["x"] = ev.pageX
  dragStartPos["y"] = ev.pageY

proc onmouseup(ev: dom.Event) =
  let ev = MouseEvent(ev)
  let distanceX = abs(dragStartPos["x"] - ev.pageX)
  let distanceY = abs(dragStartPos["y"] - ev.pageY)
  if distanceX > 50 or distanceY > 50:
    if distanceX > distanceY:
      if dragStartPos["x"] > ev.pageX:
        board.move(Left)
      else:
        board.move(Right)
    else:
      if dragStartPos["y"] > ev.pageY:
        board.move(Up)
      else:
        board.move(Down)
    redraw(kxi)

window.addEventListener("keydown", onkeydown)
window.addEventListener("mousedown", onmousedown)
window.addEventListener("mouseup", onmouseup)

proc init() =
  if hasItem("k2048::board"):
    board = ($getItem("k2048::board")).fromJson(Board)
  else:
    newBoard()

  if hasItem("k2048::score"):
    score = getItem("k2048::score").parseInt
  else:
    score = 0

  isGameOver = not board.canMove()

init()

setRenderer(createDom)