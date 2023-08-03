SECTION "Input Code", ROM0

;; Stores button input data into [wInput].
;;
;; [wInput] Bit 0 - Start
;; [wInput] Bit 1 - Select
;; [wInput] Bit 2 - A
;; [wInput] Bit 3 - B
;; [wInput] Bit 4 - Right
;; [wInput] Bit 5 - Left
;; [wInput] Bit 6 - Up
;; [wInput] Bit 7 - Down
ReadInput:
    ;; Configure controls to read direction inputs
    ld a, P1F_GET_DPAD
    ldh [rP1], a

    ;; Read directional input 5x to stabilize
    rept 5
    ldh a, [rP1]
    endr

    ;; Store directional control information in the upper 4
    ;; bits of register b
    and a, $0F      ; Clear upper 4 bits
    rla             ; Move lower 4 bits over to the upper 4 bits
    rla
    rla
    rla
    ld b, a         ; Store upper 4 bits in register b

    ;; Configure controls to read button inputs
    ld a, P1F_GET_DPAD
    ldh [rP1], a

    ;; Read button input 5x to stabilize
    rept 5
    ldh a, [rP1]
    endr

    ;; Release the controller
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ;; Copy the directional input data to register b
    and a, $0F       ; Clear upper bits
    or a, b          ; Combine with stored upper bits in register b

    ;; Store input in [wInput] work ram
    ld [wInput], a
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
