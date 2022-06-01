;; Copy data from [arg1] to [arg2] until a NULL byte
;; is reached.
;;
;; Overwrites: de, hl
m_strcpy: MACRO
  ld de, \1
  ld hl, \2
  call strcpy
endm

;; Load a memory address into register [a].
;;
;; Overwrites: hl, a
ld_to_a: MACRO
  ld hl, \1
  cp a, [hl]
endm

;; Return if register [a] < [arg1]
ret_if_a_lt: MACRO
  ld hl, \1
  cp a, [hl]
  ret nc
endm

;; Return if register [a] >= [arg1]
ret_if_a_gt: MACRO
  ld hl, \1
  cp a, [hl]
  ret c
endm