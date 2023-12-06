import std/random
include karax / prelude
import karax / kdom

type Direction = enum
  Left
  Down
  Up
  Right

var
  board: seq[seq[int]]
  score = 0

proc countEmptyTile(): int =
  result = 0
  for row in board:
    for value in row:
      if value == 0:
        inc(result)

proc addTile() =
  let emptyTileNum = countEmptyTile()
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

proc init() =
  board = @[
    @[0, 0, 0, 0],
    @[0, 0, 0, 0],
    @[0, 0, 0, 0],
    @[0, 0, 0, 0]
  ]
  addTile()

proc move(dir: Direction) =
  let tmp = board
  # ここ短かくしたい
  case dir
  of Direction.Left:
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
            score += value * 2
          else:
            break
  of Direction.Down:
    for y in countdown(3, 0):
      for x in countup(0, 3):
        let value = board[y][x]
        if value == 0: continue
        var ny = y
        while true:
          inc(ny)
          if ny > 3: break
          elif board[ny][x] == 0:
            board[ny-1][x] = 0
            board[ny][x] = value
          elif board[ny][x] == value:
            board[ny-1][x] = 0
            board[ny][x] = value * 2
            score += value * 2
          else:
            break
  of Direction.Up:
    for y in countup(0, 3):
      for x in countup(0, 3):
        let value = board[y][x]
        if value == 0: continue
        var ny = y
        while true:
          dec(ny)
          if ny < 0: break
          elif board[ny][x] == 0:
            board[ny+1][x] = 0
            board[ny][x] = value
          elif board[ny][x] == value:
            board[ny+1][x] = 0
            board[ny][x] = value * 2
            score += value * 2
          else:
            break
  of Direction.Right:
    for y in countup(0, 3):
      for x in countdown(3, 0):
        let value = board[y][x]
        if value == 0: continue
        var nx = x
        while true:
          inc(nx)
          if nx > 3: break
          elif board[y][nx] == 0:
            board[y][nx-1] = 0
            board[y][nx] = value
          elif board[y][nx] == value:
            board[y][nx-1] = 0
            board[y][nx] = value * 2
            score += value * 2
          else:
            break
  if tmp != board:
    addTile()

proc renderTile(value: int): VNode =
  result = buildHtml(tdiv(class="text-center font-bold text-[30px] leading-[100px] bg-sky-300")):
    text($value)

proc renderCell(): VNode =
  result = buildHtml(tdiv(class="w-[100px] h-[100px] bg-gray-500"))

proc renderBoard(): VNode =
  result = buildHtml(tdiv(class="grid grid-cols-4 gap-2 my-10")):
    for row in board:
      for value in row:
        renderCell():
          if value != 0:
            renderTile(value)

proc renderScore(): VNode =
  result = buildHtml(tdiv(class="w-full p-3 bg-sky-700 text-sky-100 rounded-md text-end")):
    text($score)

proc renderNewButton(): VNode =
  result = buildHtml(button(class="p-3 bg-sky-700 text-sky-100 rounded-md")):
    text("New")
    proc onclick() =
      init()

proc createDom(): VNode =
  result = buildHtml(tdiv(class="w-fit mx-auto my-10")):
    tdiv(class="flex gap-3"):
      renderScore()
      renderNewButton()
    renderBoard()
    tdiv(class="[&>a]:text-blue-700"):
      text("未完成")
      br()
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
  of "ArrowLeft":
    move(Left)
  of "ArrowDown":
    move(Down)
  of "ArrowUp":
    move(Up)
  of "ArrowRight":
    move(Right)
  redraw(kxi)

window.addEventListener("keydown", onkeydown)

init()

setRenderer(createDom)