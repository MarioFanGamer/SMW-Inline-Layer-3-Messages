;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Info Box Disassembly
; By Sonikku
; A disassembly of the Info Box used in SMW. It acts
; exactly the same as the original. Can be modified for
; other purposes, if needed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Here's the stuff you are able to edit without too much 
; knowledge of ASM.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SND_message_hit = $22		; Sound effect to play when message is hit
!BNK_message_hit = $1DFC	; Bank to use for sound effect to play when message is hit

Tilemap: db $C0,$A6			; Tilemap
YPOS:	db $00,$04,$07,$08,$08,$07,$04,$00,$00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB
                    PHK
                    PLB
                    JSR SPRITE_ROUTINE
                    PLB
					print "INIT ",pc
                    RTL     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_ROUTINE:
	JSL $01B44F|!BankB ; Load invisible solid block routine.
	
	LDA #$03
	%SubOffScreen()
	
	;%GetDrawInfo()
	
	LDA !15AC,x
	BEQ +
	DEC
	BNE +
	LDA !1594,x
	STA $13BF|!Base2
+	LDA !1558,x	; If timer for sprite..
	CMP #$01	; isn't 1..
	BNE CODE_038D93 ; Set Y position.
	LDA #!SND_message_hit
	STA !BNK_message_hit|!Base2
	STZ !1558,x	; Restore timer.
	STZ !C2,x	; Make it so it can be hit again.
	LDA $13BF|!Base2
	STA !1594,x
	%BEC(.vanilla)
	LDA !extra_byte_1,x	; Store message number to $13BF directly
	STA $13BF|!Base2
	BRA .shared

.vanilla
	LDA !extra_byte_1,x
	BEQ .default
	STA $13BF|!Base2
	LDA #$03
	STA !15AC,x
.default
	LDA !E4,x	; Load X position..
	LSR		; ..
	LSR		; ..
	LSR		; ..
	LSR		; ..
	AND #$01	; And make the sprite..
	INC		; Display its message..
	STA $1426|!Base2	; Based on its X position.
.shared
	LDA #$03
	STA !15AC,x
	LDA #!DEF_time_explode+1
	STA !1540,x
CODE_038D93:
	LDA !1558,x	; I just took this code out of all.log.
	LSR		; I didn't bother commenting it..
	TAY		; Since I don't really have the patience to.
	LDA $1C		; This code wasn't really documented..
	PHA		; In all.log to begin with..
	CLC		; So I only know this code sets the Y position..
	ADC YPOS,y	; Of the tile..
	STA $1C		; When Mario hits this sprite..
	LDA $1D		; from the bottom..
	PHA		; ..
	ADC #$00	; ..
	STA $1D		; ..
	JSL $0190B2|!BankB	; Load generic graphics routine.
	LDX $15E9|!Base2
	PLA		; Pull A.
	STA $1D		; Store to Layer 1 Y position (High byte).
	PLA		; Pull A.
	STA $1C		; And store to Layer 1 Y position (Low byte).
	RTS		; Return.