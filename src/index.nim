include karax / prelude

var board = @[
  @[2, 0, 0, 16],
  @[0, 4, 0, 0],
  @[0, 0, 0, 0],
  @[0, 0, 0, 8]
]

proc createTile(value: int): VNode =
  result = buildHtml(tdiv(class="w-[100px] h-[100px] text-center font-bold text-[30px] leading-[100px] bg-sky-200")):
    if value != 0:
      text($value)

proc createBoard(): VNode =
  result = buildHtml(tdiv(class="w-fit grid grid-cols-4 gap-2")):
    for row in board:
      for value in row:
        createTile(value)

proc createController(): VNode =
  result = buildHtml(tdiv):
    button():
      text("←")
      proc onclick(ev: Event, n: VNode) =
        for y in countup(0, 3):
          for x in countup(0, 3):
            let value = board[y][x]
            if value == 0: continue
            var nx = x
            while true:
              echo "loop left"
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
    button():
      text("↓")
      proc onclick(ev: Event, n: VNode) =
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

proc createDom(): VNode =
  result = buildHtml(tdiv):
    createBoard()
    createController()

setRenderer(createDom)