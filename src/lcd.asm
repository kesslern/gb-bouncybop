SECTION "LCD Code", ROM0

InitLCD:
    ; Init palette
    ld a, %11011000
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a

    ; Init both scroll registers to zero
    xor a
    ldh [rSCY], a
    ldh [rSCX], a

    ; Enable vblank interrupt by enabling bit 0 of the Interrupt Enable register
    ldh a, [rIE]
    set 0, a
    ldh [rIE], a

    ret

StartLCD:
    ; * Enable LCD
    ; * Turn on background display
    ; * Use first block of tile data starting at 0x8000
    ; * Use 8x8 tiles for sprites
    ; * Enable sprites
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_BLK01|LCDCF_OBJ8|LCDCF_OBJON
    ldh [rLCDC], a
    ret


StopLCD:
    ; Load the LCD control register
    ldh a, [rLCDC]
    ; Rotate left to set the carry flag based on the most significant bit
    ; Most significant bit is on if the LCD and PPU are enabled
    rlca
    ; No carry means the LCD is already off
    ret nc

;; Loop until the LCD has drawn each line on the screen
.wait:
    ldh a, [rLY]
    cp 145
    jr nz, .wait

    ; Disable the most significant bit on the LCD control register
    ; to disable the LCD and PPU
    ldh  a, [rLCDC]
    res 7, a
    ldh  [rLCDC], a

    ret
