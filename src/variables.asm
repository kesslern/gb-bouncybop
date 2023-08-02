SECTION "Variables", WRAM0
ramINPUT:
  ds 1

ramBALL_X_DIR:
  ds 1
ramBALL_Y_DIR:
  ds 1

should_delete_x:
  ds 1
should_delete_y:
  ds 1

SECTION "OAM Data",WRAM0,ALIGN[8]
ramOAM:

; Sprite attribute locations in OAM mirror
; Sprites 0-3 are paddles
ramPADDLE_Y:
  ds 1
ramPADDLE_X:
  ds 1
ramPADDLE_TILE:
  ds 1
ramPADDLE_ATTR:
  ds 1

  ds 4 * (PADDLE_TILE_WIDTH-1)

; Sprite 4 is the ball
ramBALL_Y:
  ds 1
ramBALL_X:
  ds 1
ramBALL_TILE:
  ds 1
ramBALL_ATTR:
  ds 1

ramOAM_SPRITE_END:
  ds 160 - (ramOAM_SPRITE_END - ramOAM)
ramOAM_END:
