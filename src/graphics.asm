SECTION "DMA Code", ROM0
InitDMA:
    ; Zero out memory to copy to OAM
    ld hl, ramOAM
    ld bc, $160
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

SECTION "Graphics Rendering Code", ROM0

