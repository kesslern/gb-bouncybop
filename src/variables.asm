SECTION "Variables", WRAM0
wInput:
  ds 1

wBallXDir:
  ds 1
wBallYDir:
  ds 1

wShouldDeleteX:
  ds 1
wShouldDeleteY:
  ds 1

SECTION "OAM Data",WRAM0,ALIGN[8]
ramOAM:

; Sprite attribute locations in OAM mirror
; Sprites 0-3 are paddles
wOamPaddleY:
  ds 1
wOamPaddleX:
  ds 1
wOamPaddleTile:
  ds 1
wOamPaddleAttr:
  ds 1

  ds 4 * (PADDLE_TILE_WIDTH-1)

; Sprite 4 is the ball
wOamBallY:
  ds 1
wOamBallX:
  ds 1
wOamBallTile:
  ds 1
wOamBallAttr:
  ds 1

wOamSpriteEnd:
  ds 160 - (wOamSpriteEnd - ramOAM)
ramOAM_END:
