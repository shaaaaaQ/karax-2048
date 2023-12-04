include karax / prelude

proc tile(value: int): VNode =
  result = buildHtml(tdiv(class="w-[100px] h-[100px] text-center font-bold text-[30px] leading-[100px] bg-sky-200")):
      if value != 0:
        text($value)

proc board(): VNode =
  result = buildHtml(tdiv(class="w-fit grid grid-cols-4 gap-2")):
    tile(0)
    tile(2)
    tile(16)
    tile(4)
    tile(0)
    tile(16)
    tile(4)
    tile(2)
    tile(16)
    tile(0)
    tile(2)
    tile(16)
    tile(4)
    tile(2)
    tile(0)
    tile(16)

proc createDom(): VNode =
  result = buildHtml(tdiv):
    board()

setRenderer(createDom)