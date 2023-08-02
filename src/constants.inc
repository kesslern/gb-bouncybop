PADDLE_TILE_WIDTH EQU 4  ; Paddle is 4 tiles wide
PADDLE_Y EQU 145

PADDLE_X_MIN EQU 8
PADDLE_X_MAX EQU 160 - (8 * PADDLE_TILE_WIDTH) + 8

BALL_X_MIN EQU 8
BALL_X_MAX EQU 161
BALL_Y_MIN EQU 16
BALL_Y_MAX EQU 144 + 8

BLOCKS_HEIGHT EQU 7
BLOCKS_WIDTH  EQU 8

;;; TODO: Convert to [wRAM] section

; OAM mirror - 100 bytes
ramOAM   EQU _RAM + $100 ; $C100

; Sprite attribute locations in OAM mirror
; Sprites 0-3 are paddles
ramPADDLE_Y    EQU ramOAM + $0
ramPADDLE_X    EQU ramOAM + $1
ramPADDLE_TILE EQU ramOAM + $2
ramPADDLE_ATTR EQU ramOAM + $3

; Sprite 4 is the ball
ramBALL_Y    EQU ramOAM + 4 * PADDLE_TILE_WIDTH + $0
ramBALL_X    EQU ramOAM + 4 * PADDLE_TILE_WIDTH + $1
ramBALL_TILE EQU ramOAM + 4 * PADDLE_TILE_WIDTH + $2
ramBALL_ATTR EQU ramOAM + 4 * PADDLE_TILE_WIDTH + $3
