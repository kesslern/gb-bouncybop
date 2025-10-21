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

IsBlockTile:
    cp a, $05
    ret z
    cp a, $06
    ret

HandleBlockBounce:
    ld a, [hl]
    cp a, $05
    ld [hl], 0
    jr nz, .leftHit

    inc hl
    ld [hl], 0
    ret

    .leftHit:
    dec hl
    ld [hl], 0
    ret

BounceAgainstBlocks:
.bounceTop:
    ld a, [wOamBallX]
    sub a, 4
    ld b, a
    ld a, [wOamBallY]
    sub a, 16
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsBlockTile
    jr nz, .bounceRight

    ld a, 1
    ld [wBallYDir], a
    call HandleBlockBounce

    .bounceRight:
    ld a, [wOamBallX]
    ld b, a
    ld a, [wOamBallY]
    sub a, 12
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsBlockTile
    jr nz, .bounceLeft

    ld a, -1
    ld [wBallXDir], a
    call HandleBlockBounce

    .bounceLeft:
    ld a, [wOamBallX]
    sub a, 8
    ld b, a
    ld a, [wOamBallY]
    sub a, 12
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsBlockTile
    jr nz, .bounceBottom

    ld a, 1
    ld [wBallXDir], a
    call HandleBlockBounce

    .bounceBottom:
    ld a, [wOamBallX]
    sub a, 4
    ld b, a
    ld a, [wOamBallY]
    sub a, 8
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsBlockTile
    ret nz

    ld a, -1
    ld [wBallYDir], a
    call HandleBlockBounce

    ret
