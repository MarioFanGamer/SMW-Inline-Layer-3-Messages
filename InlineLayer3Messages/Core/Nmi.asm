includefrom "InlineLayer3Messages"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Inline Layer 3 Messages NMI code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This file handles the v-blank code for the patch.
; All it does is to preserve and restore the portion of
; the tilemap where the message appears.
; An UberASM alternative also exists as a separate file.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print " Message NMI code: $",pc

HijackNmi:
    LDA MessageNumber       ; Checks for an active message to prevent the game from crashing by other uses of MessageState
    BEQ .Return
    if !FixRetry
        CMP #$08            ; First retry value is 08
        BCS .Return
    endif
    PHB
    PHK
    PLB
    LDX MessageState
    JSR (MessageStates,x)
    PLB
.Return
    
; Restore
    LDA $143A|!addr
    BEQ +
JML $008212|!bank
+
JML $008217|!bank


MessageStates:
dw .Return
dw .BackupLayer3
dw .Return
dw .Return
dw .RestoreLayer3
dw .Return


; Backs up the row of layer 3.
.BackupLayer3:
    JSR Initialisation
    BCC ..TwoReads
    
    LDA #$0280
    STA $02
    JSR ReadLayer3
    SEP #$20
RTS

..TwoReads
    JSR ReadLayer3
    LDA $00
    AND #~$03E0
    EOR #$0800
    STA $00
    LDA $04
    CLC : ADC $02
    STA $04
    LDA #$0280
    SEC : SBC $02
    STA $02
    JSR ReadLayer3
    SEP #$20
.Return
RTS


; Restores the layer 3 tilemap at the message position
.RestoreLayer3:
    JSR Initialisation
    BCC ..TwoWrites

    LDA #$0280
    STA $02
    JSR WriteLayer3
    SEP #$20
RTS

..TwoWrites
    JSR WriteLayer3
    LDA $00
    AND #~$03E0
    EOR #$0800
    STA $00
    LDA $04
    CLC : ADC $02
    STA $04
    LDA #$0280
    SEC : SBC $02
    STA $02
    JSR WriteLayer3
    SEP #$20
RTS


; Initialises the read/write by getting the VRAM address as well as set the state.
; Output:
;  $00 (16-bit): VRAM address of message
;  $02 (16-bit): Rows to upload * 2
;  $04 (16-bit): Pointer to buffer
;  C: Set if message doesn't write through the subtilemap border
Initialisation:
    LDA #$80
    STA $2115
    REP #$30
    LDA.w #Bg3Buffer
    STA $04
if !FastNmi
    LDA MessageVram
    AND #~$001F
    STA $00
    AND #$03E0
else
    LDY #$0000
    LDA MirBG3YOFS
    CLC : ADC #$0034
    BIT #$0100
    BEQ +
    INY #2
+   ASL #2
    AND #$03E0
    PHA
    STA $00
    TYA
    XBA
    ASL #2                  ; Y << 10
    ORA $00
    ORA #!Layer3Tilemap
    STA $00
    PLA
endif
    ASL
    EOR #$07FF
    INC
    STA $02
    SEP #$10
    LDY MessageTimer
    BEQ .leftHalf
    LDA $00
    EOR #$0400
    STA $00
    LDA $04
    CLC : ADC #$0280
    STA $04
    LDA MessageState
    INC
    INC
    STA MessageState
.leftHalf
    LDY #$50
    STY MessageTimer
    LDA $02
    CMP #$0280
RTS


; Reads a subtilemap row
; Input:
;  $00 (16-bit): VRAM address to read
;  $02 (16-bit): Rows to upload * 2
;  $04 (16-bit): Pointer to buffer
ReadLayer3:
    LDA $00
    STA $2116
    LDA $2139               ; Need to read one byte due to VRAM quirks
    LDA #$3981
    STA $4300
    LDA $04
    STA $4302
    LDY.b #bank(Bg3Buffer)
    STY $4304
    LDA $02
    STA $4305
    LDY #$01
    STY $420B
RTS


; Writes to a subtilemap row
; Input:
;  $00 (16-bit): VRAM address to write
;  $02 (16-bit): Rows to upload * 2
;  $04 (16-bit): Pointer to buffer
WriteLayer3:
    LDA $00
    STA $2116
    LDA #$1801
    STA $4300
    LDA $04
    STA $4302
    LDY.b #bank(Bg3Buffer)
    STY $4304
    LDA $02
    STA $4305
    LDY #$01
    STY $420B
RTS
