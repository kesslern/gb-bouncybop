SECTION "Input Code", ROM0

;; Stores button input data into [ramINPUT].
;;
;; [ramINPUT] Bit 0 - Start
;; [ramINPUT] Bit 1 - Select
;; [ramINPUT] Bit 2 - A
;; [ramINPUT] Bit 3 - B
;; [ramINPUT] Bit 4 - Right
;; [ramINPUT] Bit 5 - Left
;; [ramINPUT] Bit 6 - Up
;; [ramINPUT] Bit 7 - Down
ReadInput:
    ;; Configure controls to read direction inputs
    ld a, %00100000
    ld [rP1], a

    ;; Read directional input 5x to stabilize
    rept 5
    ld a, [rP1]
    endr

    ;; Store directional control information in the upper 4
    ;; bits of register b
    and a, $0F       ; Clear upper 4 bits
    rla              ; Move lower 4 bits over to the upper 4 bits
    rla
    rla
    rla
    ld b, a          ; Store upper 4 bits in register b

    ;; Configure controls to read button inputs
    ld a, %00010000
    ld [rP1], a

    ;; Read button input 5x to stabilize
    rept 5
    ld a, [rP1]
    endr

    ;; Copy the directional input data to register b
    and a, $0F       ; Clear upper bits
    or a, b          ; Combine with stored upper bits in register b

    ;; Store input in [ramINPUT] work ram
    ld [ramINPUT], a
    ret

CheckBallBounds:
    ld a, [ramBALL_X]
    cp a, BALL_X_MIN
    jr nz, .next1
    ld a, 1
    ld [ramBALL_X_DIR], a
.next1
    ld a, [ramBALL_X]
    cp a, BALL_X_MAX
    jr nz, .next2
    ld a, -1
    ld [ramBALL_X_DIR], a
.next2
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MIN
    jr nz, .next3
    ld a, 1
    ld [ramBALL_Y_DIR], a
.next3
    ; This can be removed when death is added
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MAX
    jr nz, .next4
    ld a, -1
    ld [ramBALL_Y_DIR], a
.next4
    ret

CheckDeath:
    ;; Temporary death removal until collision works
    ret
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MAX
    jr nz, .done
    xor a, a
    ld [ramBALL_X_DIR], a
    ld [ramBALL_Y_DIR], a
.done
    ret

CheckPaddleCollision:
    ld a, [ramBALL_Y]

    ;; Return if ball Y won't collide with paddle
    cp a, PADDLE_Y-4
    ret nz

    ;; Return if ball X won't collide with paddle
        ;; Check if ball is to left side
        ld a, [ramPADDLE_X]
        sub a, 5 ; subtract to collide with middle
        ret_if_a_lt ramBALL_X

        add a, 5 + PADDLE_TILE_WIDTH * 8
        ret_if_a_lt
        cp a, [hl]
        ret c

    ld a, -1
    ld [ramBALL_Y_DIR], a
    ret

MoveBall:
    ld hl, ramBALL_X
    ld a, [ramBALL_X_DIR]
    add a, [hl]
    ld [hl], a
    ld hl, ramBALL_Y
    ld a, [ramBALL_Y_DIR]
    add a, [hl]
    ld [hl], a
    ret
