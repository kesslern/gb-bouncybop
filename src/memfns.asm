SECTION "Memory functions", ROM0


;; Copy [arg3] bytes from [arg1] to [arg2].
;;
;; Overwrites: a, bc, de, hl
MACRO m_memcpy
  ld bc, \3
  ld de, \1
  ld hl, \2
  call memcpy
endm

; Copy a chunk of memory of known size.
; @param bc - Number of bytes to copy
; @param de - Source address
; @param hl - Destination address
memcpy:
    ld a, [de]  ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de      ; Increment source address
    dec bc      ; Decrement count
    ld a, b     ; Check if count is 0
    or c
    jr nz, memcpy
    ret

;; Zero [arg2] bytes at [arg1].
;;
;; Overwrites: a, bc, de, hl
MACRO m_zero
  ld bc, \2
  ld hl, \1
  call zero
endm

; Zero a chunk of memory.
; @param bc - Number of bytes to zero
; @param hl - Start address
zero:
    xor a, a
    ld [hli], a ; Place it at the destination, incrementing hl
    dec bc      ; Decrement count
    ld a, b     ; Check if count is 0
    or c
    jr nz, zero
    ret

;; Copy data from [arg1] to [arg2] until a NULL byte
;; is reached.
;;
;; Overwrites: de, hl
MACRO m_strcpy
  ld de, \1
  ld hl, \2
  call strcpy
endm

; Copy a 0-terminated string to VRAM
; @param de - Source address
; @param hl - Destination address
strcpy:
    ld a, [de]  ; Grab 1 byte from source address
    ld [hli], a ; Write to memory & increment destination addr
    inc de      ; Increment source addr
    and a       ; Check if the byte we just copied is zero
    jr nz, strcpy
    ret