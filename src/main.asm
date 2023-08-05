INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INCLUDE "variables.asm"
INCLUDE "data.asm"
INCLUDE "init.asm"
INCLUDE "game_logic.asm"
INCLUDE "graphics.asm"
INCLUDE "header.asm"
INCLUDE "input.asm"
INCLUDE "lcd.asm"
INCLUDE "memfns.asm"

SECTION "vBlank interrupt handler", ROM0[$0040]
    ; call _HRAM
    reti

SECTION "Game code", ROM0[$0150]
Start:
    ; Disable interrupts during initialization
    di
    call StopLCD
    call InitLCD
    call InitDMA
    call InitBallRAM
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
    ld a, [wBallYDir]
    cp -1
    jr nz, .end

    ld a, [wOamBallY]
    cp 88
    jr nz, .end

    ;; TODO: Bounce conditionally based on block collision
    ld a, 1
    ld [wBallYDir], a

    call CheckBrickCollisionMovingUp

.end:
    call MoveBall
    call MovePaddle

    ; Wait for VBlank and shadow OAM to be copied via the interrupt
    halt

    ;; Here we can access and update the vRAM and update OAM
    call DeleteIfCollision

    ;; TODO: Bounce conditionally based on block collision
    call _HRAM


    jp Loop
