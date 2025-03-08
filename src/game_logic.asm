SECTION "Game Logic", ROM0

MovePaddle:
  ld a, [wInput]

.left:
  ; Check if left button pressed.
  bit 5, a
  jr nz, .right

  ; Left is pressed. Ensure there's space to move left.
  ld hl, wOamPaddleX
  ld a, [hl]
  cp a, PADDLE_X_MIN
  ret z

  ; Set new X location and update.
  ld a, [hl]
  sub a, 2
  jr .update


.right:
  ; Check if right button pressed.
  bit 4, a
  ret nz

  ; Right is pressed. Ensure there's space to move right.
  ld hl, wOamPaddleX
  ld a, PADDLE_X_MAX
  cp a, [hl]
  ret z

  ; Set new X location and update.
  ld a, [hl]
  add a, 2

  ; Update the paddle sprite locations.
  ; a  - left sprite X location
  ; hl - left sprite X location in memory
.update
  ld [hl], a
  REPT 3
  inc l
  inc l
  inc l
  inc l
  add a, 8
  ld [hl], a
  ENDR

  ret

MoveBall:
  ld hl, wOamBallX
  ld a, [wBallXDir]
  add a, [hl]
  ld [hl], a

  ld hl, wOamBallY
  ld a, [wBallYDir]
  add a, [hl]
  ld [hl], a
  ret

BounceBallAgainstWalls:
  ld a, [wOamBallX]
  cp a, BALL_X_MIN
  jr nz, .next1
  ld a, 1
  ld [wBallXDir], a
.next1
  ld a, [wOamBallX]
  cp a, BALL_X_MAX
  jr nz, .next2
  ld a, -1
  ld [wBallXDir], a
.next2
  ld a, [wOamBallY]
  cp a, BALL_Y_MIN
  jr nz, .next3
  ld a, 1
  ld [wBallYDir], a
.next3
  ; This can be removed when death is added
  ld a, [wOamBallY]
  cp a, BALL_Y_MAX
  jr nz, .next4
  ld a, -1
  ld [wBallYDir], a
.next4
  ret

CheckDeath:
  ;; Temporary death removal until collision works
  ret
  ld a, [wOamBallY]
  cp a, BALL_Y_MAX
  jr nz, .done
  xor a, a
  ld [wBallXDir], a
  ld [wBallYDir], a
.done
  ret

CheckPaddleCollision:
  ;; Return if ball is moving up
  ld a, [wBallYDir]
  cp a, -1
  ret z

  ld a, [wOamBallY]

  ;; Return if ball Y won't collide with paddle
  cp a, PADDLE_Y-4
  ret nz

  ;; Return if ball X won't collide with paddle
  ;; Check if ball is to left side
  ld a, [wOamPaddleX]
  sub a, 5 ; subtract to collide with middle
  ld hl, wOamBallX
  cp a, [hl]
  ret nc

  add a, 5 + PADDLE_TILE_WIDTH * 8
  cp a, [hl]
  ret c

  ld a, -1
  ld [wBallYDir], a
  ret

;; Check if OAM X/Y coordanets are inside the blocks on the background
;; Params: d = y, e = x
CheckCoordinateInsideBlocks:

CheckBrickCollisionMovingUp:
  ;; Return if ball is moving down
  ld a, [wBallYDir]
  cp 1
  ret z

  ld a, [wOamBallY]
  sub a, 89
  ret nc

  ld a, [wOamBallY]
  sub a, 24
  ret c

  ld a, [wOamBallX]
  sub a, 23
  ret c

  ld a, [wOamBallX]
  sub a, 16+16*8
  ret nc

  ;; Load ball Y and remove lowest 3 bits to floor to nearest 8
  ld a, [wOamBallY]
  srl a
  srl a
  srl a

  ;; Then subtract 5 to get the y index of the block on the screen
  sub 5
  ld [wShouldDeleteY], a
  ld d, a

  ld a, [wOamBallX]
  ;; Line up OAM coordinate with background coordinate
  sub 8
  ;; Remove lowest 4 bits to floor to nearest 16
  srl a
  srl a
  srl a
  srl a
  ;; Compensate for left gutter where no blocks are
  dec a
  ld [wShouldDeleteX], a

  ret

; If a is z on return, then we collided with a brick
DeleteIfCollision:
  ld a, [wShouldDeleteY]
  cp -1
  ret z

  ld a, [wShouldDeleteY]
  ld d, a
  ld a, [wShouldDeleteX]
  ld e, a

  ;;; Calculate OAM offset
  ;; e is the x
  ;; d is the y
  ;; hl is result

  ld hl, 64

.addypart:
  ; Add 32 to hl for each row counted in e
  ld a, d
  cp 0
  jr z, .addxpart

  ld a, l
  add a, 32
  ld l, a
  jr nc , .addypart2
  inc h

.addypart2:
  dec d
  jr .addypart

.addxpart:
  ld bc, 2 + _SCRN0
  sla e ; Multiply by 2 because blocks are 2 wide
  add hl, de
  add hl, bc

  ld a, [hl]
  jr nz, .hit

  ;; Return nz == no hit
  ld a, -1
  ld [wShouldDeleteX], a
  ld [wShouldDeleteY], a
  ret

.hit:
  xor a
  ld [hli], a
  ld [hl], a

  ld a, -1
  ld [wShouldDeleteX], a
  ld [wShouldDeleteY], a

  ld a, 0
  cp -1
  ret

; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
GetTileByPixel:
    ; First, we need to divide by 8 to convert a pixel position to a tile position.
    ; After this we want to multiply the Y position by 32.
    ; These operations effectively cancel out so we only need to mask the Y value.
    ld a, c
    and a, %11111000
    ld l, a
    ld h, 0
    ; Now we have the position * 8 in hl
    add hl, hl ; position * 16
    add hl, hl ; position * 32
    ; Convert the X position to an offset.
    ld a, b
    srl a ; a / 2
    srl a ; a / 4
    srl a ; a / 8
    ; Add the two offsets together.
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Add the offset to the tilemap's base address, and we are done!
    ld bc, $9800
    add hl, bc
    ret
