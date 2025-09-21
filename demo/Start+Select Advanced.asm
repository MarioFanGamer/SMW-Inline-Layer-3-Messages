lorom

!DefaultExit = $02	; If the level's exit type is $00: The list of options can be seen below at "Exception:"

!addr = $0000
!bank = $800000

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
endif

org $00A264|!bank
autoclean JML StartSelect

freedata

StartSelect:
	TYX
	LDA.l Exceptions,x
	BNE +
	LDA #!DefaultExit
+	DEC
	BEQ .Vanilla
	DEC
	BEQ .AlwaysExit
	DEC
	BEQ .GetKilled
	DEC
	BEQ .FinishLevel
	BNE .Return
.Vanilla:
	LDA $1EA2|!addr,y
	BPL .Return
.AlwaysExit:
JML $00A269|!bank

.GetKilled:
	LDA $1EA2|!addr,y	; When beaten, you can safely exit the level.
	BMI .AlwaysExit
	LDA $0DBE|!addr		; If on the last life...
	BEQ .Return			; ... do nothing to prevent a game over.
	LDA #$12			; Hack: The music will stay silent otherwise.
	STA $1DF9|!addr
	STZ $13D4|!addr
	JSL $00F606|!bank
.Return:
JML $00A289|!bank

.FinishLevel:
	LDA $0DD5|!addr		; If a special exit...
	BMI .Return
	LDA #$01			; Activate the normal exit.
JML $00A27B|!bank

assert !DefaultExit, "!DefaultExit may not be 0."

; What actions to perform on certain levels when you exit the level with start + select:

; If the value is $00, use !DefaultExit.
; If the value is $01, use the vanilla system.
; If the value is $02, you can exit the level regardless if you have beaten it or not.
; If the value is $03, you can exit the level but if you haven't beaten it yet, you get killed (except on the last life, of course).
; If the value is $04, activate the regular exit (but not secret exit, one is enough). Careful of levels without exits!
; If the value is $05, you can't exit the level regardless if you have beaten it or not.

; Always leave level 0 to $00 (or currently $05) and use the other values if you know what you're doing.
; This applies mostly for the intro which puts you back at the start.
; The bonus level is a special exception so it's unaffected by start+select (by default).

Exceptions:
db $05,$00,$00,$02,$00,$00,$00,$00    ; Levels   0 -  7
db $05,$00,$00,$00,$00,$00,$00,$00    ; Levels   8 -  F
db $00,$00,$00,$00,$05,$00,$00,$00    ; Levels  10 -  17
db $00,$00,$00,$00,$00,$00,$00,$00    ; Levels  18 -  1F
db $00,$00,$00,$00,$00                ; Levels  20 -  24

db     $00,$00,$00,$02,$04,$00,$00    ; Levels 100 -  17
db $00,$00,$00,$00,$00,$00,$00,$00    ; Levels 108 -  1F
db $00,$00,$00,$00,$00,$00,$00,$00    ; Levels 110 - 117
db $00,$00,$00,$05,$00,$00,$00,$00    ; Levels 118 - 11F
db $00,$05,$00,$00,$00,$00,$00,$00    ; Levels 120 - 127
db $00,$00,$00,$00,$00,$00,$00,$00    ; Levels 128 - 12F
db $00,$00,$00,$00,$00,$00,$00,$00    ; Levels 130 - 137
db $00,$00,$00,$00                    ; Levels 138 - 13B
