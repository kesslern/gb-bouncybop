SECTION "Init Code", ROM0

InitBallRAM:
    ; Init ball position
    ld a, 16
    ld [wOamBallX], a
    ld a, 140
    ld [wOamBallY], a

    ; Init ball direction
    ld a, -1
    ld [wBallYDir], a
    ld a, 1
    ld [wBallXDir], a

    ld a, -1
    ld [wShouldDeleteX], a
    ld [wShouldDeleteY], a

    ret

; Init sprite data in OAM and related sprite data in WRAM.
; Initializes a 4-tile wide paddle and the ball.
InitSprites:
    ; Set paddle Y value on paddle sprites
    ld a, PADDLE_Y
    ld [wOamPaddleY + 0 * 4], a
    ld [wOamPaddleY + 1 * 4], a
    ld [wOamPaddleY + 2 * 4], a
    ld [wOamPaddleY + 3 * 4], a

    ; Set paddle X value on paddle sprites
    ld a, 8 * (0+1)
    ld [wOamPaddleX + 0 * 4], a
    ld a, 8 * (1+1)
    ld [wOamPaddleX + 1 * 4], a
    ld a, 8 * (2+1)
    ld [wOamPaddleX + 2 * 4], a
    ld a, 8 * (3+1)
    ld [wOamPaddleX + 3 * 4], a

    ; Set paddle tiles to on the ends
    ld a, $02
    ld [wOamPaddleTile + 0 * 4], a
    ld [wOamPaddleTile + 3 * 4], a
    ; Flip X for end paddle tile
    ld a, %00100000
    ld [wOamPaddleAttr + 3 * 4], a
    ; Set middle paddle tiles
    ld a, $03
    ld [wOamPaddleTile + 1 * 4], a
    ld [wOamPaddleTile + 2 * 4], a
    ; Set ball tile
    ld a, $04
    ld [wOamBallTile], a

    ret

InitVRAM:
    ; Zero out logo tiles
    ld hl, $80D0
    ld bc, $9930 - $80D0
    call zero

    ; Zero out Nintendo logo VRAM tiles
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
        ld hl, _SCRN0 + (y+2) * $20 + (x * 2) + 2
        ld a, $05
        ld [hli], a
        ld a, $06
        ld [hli], a
    ENDR
    ENDR

    ; Add tiles created with vtGBte
    ld hl, _VRAM8000 + $20
    ld de, GBT_Tile
    ld bc, GBT_Tile_End
    call memcpy

    ret
