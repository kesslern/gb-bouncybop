SECTION "Game Logic", ROM0

InitBallRAM:
    ; Init ball position
    ld a, 16
    ld [wOamBallX], a
    ld a, 140
    ld [wOamBallY], a

    ; Init ball direction
    ld a, -1
    ld [wBallYDir], a
    ld a, 1
    ld [wBallXDir], a

    ld a, 0
    ld [wShouldDeleteX], a
    ld [wShouldDeleteY], a

    ret

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
