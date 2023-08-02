SECTION "Entry", ROM0[$0100]
    nop
    jp Start

    ds $150 - @, 0 ; Make room for the header
