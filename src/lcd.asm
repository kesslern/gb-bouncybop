SECTION "LCD Code", ROM0

InitLCD:
    ; Init palette
    ld a, %11011000
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a

    ; Init scroll registers
    xor a
    ldh [rSCY], a
    ldh [rSCX], a

    ; Enable vblank interrupt
    ldh a, [rIE]
    set 0, a
    ldh [rIE], a

    ret

StartLCD:
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_BG8000|LCDCF_OBJ8|LCDCF_OBJON
    ldh [rLCDC], a
    ret


StopLCD:
    ldh a, [rLCDC]
    rlca
    ret nc ; In this case, the LCD is already off

.wait:
    ldh a, [rLY]
    cp 145
    jr nz, .wait

    ldh  a, [rLCDC]
    res 7, a
    ldh  [rLCDC], a

    ret