INCLUDE "hardware.inc"

INCLUDE "constants.asm"
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

SECTION "Test Text", ROM0

testText:  db "HTTP://GITHUB.COM/KESSLERN", 255

DrawTextTiles:

    ld hl, testText
    ld de, $9980

DrawTextTilesLoop:

    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    ld [de], a

    inc hl
    inc de

    ; move to the next character and next background tile
    jp DrawTextTilesLoop


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
    call DrawTextTiles

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

    call MoveBall
    call MovePaddle

    halt

    call BounceAgainstBlocks

    jp Loop
