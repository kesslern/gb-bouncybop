;; Copy data from [arg1] to [arg2] until a NULL byte
;; is reached.
;;
;; Overwrites: de, hl
MACRO m_strcpy
  ld de, \1
  ld hl, \2
  call strcpy
endm
