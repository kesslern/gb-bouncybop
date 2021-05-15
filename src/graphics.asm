SECTION "Graphics Code", ROM0

; Init sprite data in OAM and related sprite data in WRAM.
; Initializes a 4-tile wide paddle and the ball.
InitSprites:

    ; Set paddle Y value on paddle sprites
    ld a, PADDLE_Y
    ld [ramPADDLE_Y + 0 * 4], a
    ld [ramPADDLE_Y + 1 * 4], a
    ld [ramPADDLE_Y + 2 * 4], a
    ld [ramPADDLE_Y + 3 * 4], a

    ; Set paddle X value on paddle sprites
    ld a, 8 * (0+1)
    ld [ramPADDLE_X + 0 * 4], a
    ld a, 8 * (1+1)
    ld [ramPADDLE_X + 1 * 4], a
    ld a, 8 * (2+1)
    ld [ramPADDLE_X + 2 * 4], a
    ld a, 8 * (3+1)
    ld [ramPADDLE_X + 3 * 4], a
    
    ; Set paddle tiles to on the ends 
    ld a, $02
    ld [ramPADDLE_TILE + 0 * 4], a
    ld [ramPADDLE_TILE + 3 * 4], a
    ; Flip X for end paddle tile
    ld a, %00100000 
    ld [ramPADDLE_ATTR + 3 * 4], a
    ; Set middle paddle tiles
    ld a, $03
    ld [ramPADDLE_TILE + 1 * 4], a
    ld [ramPADDLE_TILE + 2 * 4], a
    ;Set ball tile
    ld a, $04
    ld [ramBALL_TILE], a

    ; Init ball position
    ld a, 50
    ld [ramBALL_X], a
    ld a, 140
    ld [ramBALL_Y], a

    ; Init ball direction
    ld a, -1
    ld [ramBALL_Y_DIR], a
    ld a, 1
    ld [ramBALL_X_DIR], a

    ret

InitVRAM:
    ; Zero out Nintendo logo VRAM space
    ld hl, _VRAM8000
    ld bc, $81A0 - _VRAM8000
    call zero

    ; Draw blocks and init blocks in memory
    FOR y, 7
    FOR x, 8
        ; Rows are $20 (32) tiles wide in VRAM and 20 tiles wide on
        ; screen. 

        ; y+2 => y row + 2 offset from top
        ;    * $20 => $20 / row in VRAM
        ;    + 2 => 2 offset from left 
        ld hl, _SCRN0 + (y + 2) * $20 + 2 + (x * 2)
        ld a, $05
        ld [hli], a
        ld a, $06
        ld [hli], a
    ENDR
    ENDR

    ; Add tiles created with GBT
    ld hl, _VRAM8000 + 32
    ld de, GBT_Tile
    ld bc, 3 * 32
    call memcpy

    ret

SECTION "DMA Code", ROM0
InitDMA:
    ; Zero out memory to copy to OAM
    ld hl, ramOAM
    ld bc, $100
    call zero

    ; Copy DMA code into HRAM
    ld hl, _HRAM
    ld de, runDMA
    ld bc, dmaEnd - runDMA
    call memcpy
    ret

runDMA:
    ld a, ramOAM / $100
    ldh  [rDMA], a ;start DMA transfer (starts right after instruction)
    ld  a ,$28     ;delay...
.wait:             ;total 4x40 cycles, approx 160 μs
    dec a          ;1 cycle
    jr  nz, .wait  ;3 cycles
    ret
dmaEnd:

