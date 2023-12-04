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

proc createDom(): VNode =
  result = buildHtml(tdiv):
    createBoard()

setRenderer(createDom)