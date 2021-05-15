SECTION "LCD Code", ROM0

InitLCD:
    ; Init palette
    ld a, %11011000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a

    ; Init scroll registers
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Enable vblank interrupt
    ld a, [rIE]
    set 0, a
    ld [rIE], a

    ret
    
StartLCD:
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_BG8000|LCDCF_OBJ8|LCDCF_OBJON
    ld [rLCDC], a
    ret


StopLCD:
    ld a, [rLCDC]
    rlca
    ret nc ; In this case, the LCD is already off

.wait:
    ld a, [rLY]
    cp 145
    jr nz, .wait

    ld  a, [rLCDC]
    res 7, a
    ld  [rLCDC], a

    ret