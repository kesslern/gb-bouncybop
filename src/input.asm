SECTION "Input Code", ROM0

;; Stores button input data into [wInput].
;;
;; [wInput] Bit 0 - Start
;; [wInput] Bit 1 - Select
;; [wInput] Bit 2 - A
;; [wInput] Bit 3 - B
;; [wInput] Bit 4 - Right
;; [wInput] Bit 5 - Left
;; [wInput] Bit 6 - Up
;; [wInput] Bit 7 - Down
ReadInput:
    ;; Configure controls to read direction inputs
    ld a, P1F_GET_DPAD
    ldh [rP1], a

    ;; Read directional input 5x to stabilize
    rept 5
    ldh a, [rP1]
    endr

    ;; Store directional control information in the upper 4
    ;; bits of register b
    and a, $0F      ; Clear upper 4 bits
    rla             ; Move lower 4 bits over to the upper 4 bits
    rla
    rla
    rla
    ld b, a         ; Store upper 4 bits in register b

    ;; Configure controls to read button inputs
    ld a, P1F_GET_DPAD
    ldh [rP1], a

    ;; Read button input 5x to stabilize
    rept 5
    ldh a, [rP1]
    endr

    ;; Release the controller
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ;; Copy the directional input data to register b
    and a, $0F       ; Clear upper bits
    or a, b          ; Combine with stored upper bits in register b

    ;; Store input in [wInput] work ram
    ld [wInput], a
    ret
