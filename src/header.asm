SECTION "Header", ROM0[$0100]
    jp Start

; Space for header
REPT $0150 - $0104
    db 0
ENDR
