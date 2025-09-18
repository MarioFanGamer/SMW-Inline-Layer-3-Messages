;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Inline Layer 3 Messages UberASM NMI code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; UberASM code for handling the v-blank portion of
; Inline Layer 3 Messages.
;
; Insert this either for all levels or gamemode 14
; with UberASM Tool 2.0.
;
; Do not insert this with !HijackNmi enabled since the
; funtionality is already included by this patch.
; I even included a check for !HijackNmi.
;
; You can easily bypass it by disabling this check such as
; by temporarily setting it to 0, use a separate define
; file or w/e but at that point, you're doing it on
; purpose.
; Likewise, the patch doesn't check if the UberASM code
; has been inserted but again, by that point, you're doing
; it on purpose...
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Folder structure for finding InlineLayer3Messages
; Syntax:
;   - "./": Current folder
;   - "../": Parent folder
;   - "folder/": Folder named "folder"
; In general, UberASM will look into the directory of the
; inserting file (e.g. if this is inserted as level code,
; this will look into "levels".
; As such, I go down one folder for the UberASM main folder.
; However, I also I typically include UberASM in its own
; directory when paired together with the hack which is
; why, I go down two folders.
; Not everyone will use the same folder layout, though,
; which is why keep this a define.
!IncludeDirectory = "../../InlineLayer3Messages/"


; Internal defines, do not change
!IncludeDirectory += "Settings.asm"

incsrc !IncludeDirectory

MirBG3YOFS = $000024|!dp
MessageNumber = !MessageNumber
MessageState = !MessageState
MessageTimer = !MessageTimer
MessageVram = !MessageVram
Bg3Buffer = !Layer3Buff

if !HijackNmi
    error "Do not insert this with \!HijackNmi enabled."
endif

dpbase !dp
optimize dp always
optimize address mirrors

nmi:
    LDA MessageNumber       ; Checks for an active message to 
    BEQ .Return
    if !NmiFixRetry
        CMP #$04
        BCS .Return
    endif
    LDX MessageState
    JSR (MessageStates,x)
.Return:
RTL

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
;  $00: VRAM address of message
;  $02: Rows to upload * 2
;  $04: Pointer to buffer
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
;  $00: VRAM address to read
;  $02: Rows to upload * 2
;  $04: Pointer to buffer
ReadLayer3:
    LDA $00
    STA $2116
    LDA $2139
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
;  $00: VRAM address to write
;  $02: Rows to upload * 2
;  $04: Pointer to buffer
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
