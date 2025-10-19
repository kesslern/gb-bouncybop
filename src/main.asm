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
    call _HRAM
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

    call CheckBrickCollisionMovingUp

    call MoveBall
    call MovePaddle

    halt

    jp Loop
