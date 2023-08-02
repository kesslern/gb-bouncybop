INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INCLUDE "variables.asm"
INCLUDE "data.asm"
INCLUDE "game_logic.asm"
INCLUDE "graphics.asm"
INCLUDE "header.asm"
INCLUDE "input.asm"
INCLUDE "lcd.asm"
INCLUDE "memfns.asm"

SECTION "vBlank interrupt handler", ROM0[$0040]
    call _HRAM
    reti

SECTION "Game code", ROM0[$0150]
Start:
    ; Disable interrupts during initialization
    di
    call StopLCD
    call InitLCD
    call InitDMA
    call InitWRAM
    call InitVRAM
    call InitSprites

    ; Shut sound down
    ldh [rNR52], a

    call StartLCD

    ; Enable interrupts for main loop
    ei

Loop:
    call ReadInput
    call BounceBallAgainstWalls
    call CheckPaddleCollision
    call CheckDeath

     ; Check bounce on top while moving up
    ld a, [ramBALL_Y_DIR]
    cp -1
    jr nz, .end

    ld a, [ramBALL_Y]
    cp 88
    jr nz, .end

    ld a, 1
    ld [ramBALL_Y_DIR], a

    ; Ball Y is 88 and moving up
    ; Tile of lowest block is 9*8 + 16 = 88
    ; 88, 80, 72, 64, 56, 48, 40
    ; Shift right 3x to get the block index
    ; 88 is 0b1011000 -> 0b1011 -> 11
    ; 80 is 0b1010000 -> 0b1010 -> 10
    ; 72 is 0b1001000 -> 0b1001 -> 9
    ; 64 is 0b1000000 -> 0b1000 -> 8
    ; 56 is 0b0111000 -> 0b0111 -> 7
    ; 48 is 0b0110000 -> 0b0110 -> 6
    ; 40 is 0b0101000 -> 0b0101 -> 5
    ld a, [ramBALL_Y]
    srl a
    srl a
    srl a

    sub 5               ; Then subtract 3 to get the y index of the block
    ld [should_delete_y], a
    ld d, a

    ; Ball X is 0-152ish
    ; Remove lowest 4 bits to round to nearest 16
    ld a, [ramBALL_X]
    sub 8 ; Line up OAM coordinate with background coordinate
    srl a
    srl a
    srl a
    srl a
    dec a ; Compensate for left gutter
    ld [should_delete_x], a
    ld e, a

.end:
    call MoveBall
    call MovePaddle

    ; Wait for VBlank and shadow OAM to be copied via the interrupt
    halt

    ; Delete if we should
    ld a, [should_delete_y]
    cp 0
    jr z, Loop


    ld a, [should_delete_y]
    ld d, a
    ld a, [should_delete_x]
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
    ld a, 0
    ld [should_delete_y], a
    ld [should_delete_x], a

    jp Loop

;;; Multiply b by c and store in a
Multiply:

    ; b is the number to multiply
    ; c is the number of times to multiply
    ; d is the number of times we've multiplied
    ; e is the result

    ; Start counting multiplication at zero
    ld a, 0
    ld d, a
    ld e, 0


    ld a, c
    cp 0
    jr z, .end


.loop:
    ld a, d
    cp c
    jr z, .end

    ; Add c to a
    ld a, e
    add b
    ld e, a
    inc d

    ; Loop
    jp .loop
.end:
    ld a, e
    ret
