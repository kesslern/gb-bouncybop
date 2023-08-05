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

CheckBrickCollisionMovingUp:
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

DeleteIfCollision:
  ; Delete if we should
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
  xor a
  ld bc, 2 + _SCRN0
  sla e
  add hl, de
  add hl, bc
  ld [hli], a
  ld [hl], a

  ; Reset the should delete coordinates back to zero
  ld a, -1
  ld [wShouldDeleteY], a
  ld [wShouldDeleteX], a

  ret
