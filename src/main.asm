INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INCLUDE "data.asm"
INCLUDE "game_logic.asm"
INCLUDE "graphics.asm"
INCLUDE "header.asm"
INCLUDE "input.asm"
INCLUDE "memfns.asm"

SECTION "vBlank interrupt handler", ROM0[$0040]
    call Draw
    reti

SECTION "Game code", ROM0
Start:
    call InitLCD

    ld hl, ramBALL_Y
    ld a, 140
    ld [hl], a

    ld hl, ramBALL_Y_DIR
    ld a, -1
    ld [hl], a
    ld hl, ramBALL_X_DIR
    ld a, 1
    ld [hl], a

    ; Shut sound down
    ld [rNR52], a

    ei
    jp Loop

Loop:
    call ReadInput
    call MoveBall
    call MovePaddle
    call CheckBallBounds
    call CheckPaddleCollision
    call CheckDeath

    halt

    ; Check block collisions
    FOR y, 7

    ; Check if ball Y is at bottom of tile
    ld a, [ramBALL_Y]
    cp a, (y + 5) * 8 - 1
    jp nz, \@continue_y

    FOR x, 8
        ld hl, _SCRN0 + (y + 2) * $20 + 2 + (x * 2)
        ld a, [hl]
        cp a, $05
        jp nz, \@continue_x

        ld hl, ramBALL_X
        ; Check if ball X > left side of tile
        ld a, (3 + (x * 2)) * 8
        cp a, [hl]
        jr nc, \@continue_x

        ; Check if ball X < right side of tile
        ld a, (5 + (x * 2)) * 8
        cp a, [hl]
        jr c, \@continue_x

        ; HIT!!!
        ; Remove tile
        ld hl, _SCRN0 + (y + 2) * $20 + 2 + (x * 2)
        xor a, a
        ld [hli], a
        ld [hl], a

        ld hl, ramBALL_Y_DIR
        ld [hl], 1
        jp Loop
    \@continue_x:
    ENDR

    \@continue_y:
    ENDR

    jp Loop

Draw:
    call _HRAM
    ret
