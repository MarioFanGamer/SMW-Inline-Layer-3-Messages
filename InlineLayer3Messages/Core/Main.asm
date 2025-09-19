includefrom "InlineLayer3Messages"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Inline Layer 3 Messages main patch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This file handles the main part of drawing the message,
; decompression, window and stripe image, as well as
; handling any player interaction.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print " Message main code: $",pc

NewMessageSystem:
    PHB
    PHK
    PLB
    LDX MessageState
    JSR (MessageBoxActions,x)
    PLB
.Return
RTL

MessageBoxActions:
dw .Grow
dw .WaitForNMI
dw .GenerateMessage
dw .WaitForPlayer
dw .WaitForNMI
dw .Shrink

; Initialises the window and also let the window grow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Grow:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Disable every layer and colour maths in the window.
    LDA #$22
    STA MirW12SEL
    STA MirW34SEL
    ;LDA #$22
    STA MirCGWSEL
    LDX SwitchColour
    BEQ +
    LDA #$20            ; Don't mask out sprites if a switch message.
+   STA MirWOBJSEL

    JSR GenerateWindow
    LDA MessageTimer
    CMP #$50
    BEQ ..NextState
    CLC : ADC #$04
    STA MessageTimer
RTS

..NextState:
    LDA MessageState
    INC #2
    STA MessageState
    STZ MessageTimer

; Reduce repeated calculations by calculating the VRAM position only once.
if !FastNmi
    ; Get VRAM Address
    REP #$30
    LDY #$0000
    LDA $22
    CLC : ADC #$0034
    BIT #$0100          ; Is on right half?
    BEQ +
    INY
+   LSR #3
    AND #$001F
    STA $00
    LDA $24
    CLC : ADC #$0034
    BIT #$0100          ; Is on bottom half?
    BEQ +
    INY #2
+   ASL #2
    AND #$03E0
    ORA $00
    STA $00
    TYA
    XBA
    ASL #2              ; Y << 10
    ORA $00
    ORA #!Layer3Tilemap
    STA !MessageVram
    SEP #$30
endif
RTS

; Writes the message into a buffer and also into the tilemap.
; This process is buffered: If the message is split into two
; frames,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.GenerateMessage:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    LDA #$00
    XBA
    LDX MessageNumber
    CPX #$03
    BEQ ..YoshiMessage
if !GlobalMessages
    BCS ..LoadGlobalMessage
endif
    LDA GameTranslevel
    CMP YoshisHouseLevel
    BEQ ..YoshisHouse
    CPX #$02
BRA ..NormalMessage

..YoshiMessage:
    LDA #$00            ; Level 0
    SEC                 ; Message 2
    BRA ..NormalMessage

..YoshisHouse:
    CLC                 ; Message 1
    LDY PlayerOnYoshi   ;
    BEQ ..NormalMessage ; If on Yoshi...
    SEC                 ; Message 2
..NormalMessage:
    ; In the end:
    ; A: Translevel number
    ; C: CLC for message 1, SEC for message 2
    ; A side effect is that the stacked message exploit doesn't work anymore.
    REP #$30
    ROL
    ASL
    TAX
    LDA MessageTimer        ; Saves one byte+cycle
    PEA.w bank(MessageBuffer)|(bank(NewMessageSystem)<<8)
    bank bank(MessageBuffer)
    PLB
    AND #$0001
    BNE ..Shared
    LDY #$0000
    LDA MessageTable+1
    STA $01                 ; Fixed bank.
    LDA MessageIndex,x
    CLC : ADC MessageTable
    STA $00
if !GlobalMessages
BRA ..MessageShared

..LoadGlobalMessage:
    REP #$20
    TXA
    ASL
    CLC : ADC GlobalMessagePtrs-8,x
    STA $00                 ; Always load an empty message if no message has been defined
    BEQ ..Empty
    LDY.b #bank(GlobalMessages)
    STA $02
    LDY #$00                ; High byte of Y is always clear when Y is 8-bit
    REP #$10

..MessageShared
endif
    SEP #$20
-   LDA [$00],y
    CMP #!MessageTerminator ; If character is the message terminator: Reached the end of message
    BEQ ..Empty
    STA MessageBuffer,y
    INY
    CPY #$0090
    BNE -
    BRA ..Shared

..Empty:
    LDA #!EmptyTile
-   STA MessageBuffer,y
    INY
    CPY #$0090
    BNE -

..Shared:
    REP #$30

if !FastNmi
    LDA MessageVram
else
    ; Get VRAM Address
    LDY #$0000
    LDA MirBG3XOFS
    CLC : ADC #$0034
    BIT #$0100          ; Is on right half?
    BEQ +
    INY
+   LSR #3
    AND #$001F
    STA $00
    LDA MirBG3YOFS
    CLC : ADC #$0034
    BIT #$0100          ; Is on bottom half?
    BEQ +
    INY #2
+   ASL #2
    AND #$03E0
    ORA $00
    STA $00
    TYA
    XBA
    ASL #2              ; Y << 10
    ORA $00
    ORA #!Layer3Tilemap
endif
    STA $00

    ; Get left side's width.
    AND #$001F
    EOR #$001F
    INC
    CMP #$0014
    BCC ..Split
    LDA #$0014          ; Maximally 0x14
..Split:
    STA $02

    ; Write the message
    LDA StripeIndex
    TAX

    LDA.l MessageTimer
    AND #$0001
    STA $06
    BNE ..RightSide
    LDA.w #MessageBuffer
    STA $04
    JSR PlaceTiles
    LDA #$FFFF
    STA StripeQueue,x
    TXA
    STA StripeIndex
    PLB
    bank auto
    SEP #$30
    INC MessageTimer
RTS

; The process goes the following:
; - Set the X position to the left side of the other half.
; - Increment the text buffer by the current box with - 1 (because of the border)
; - Decrement the full width by the current width
..RightSide:
    bank bank(MessageBuffer)
    LDA.w #MessageBuffer
    CLC : ADC $02
    DEC
    STA $04
    LDA #$0014
    SEC : SBC $02
    BEQ ..SingleSide
    STA $02
    LDA $00
    AND #~$001F
    EOR #$0400
    STA $00

    JSR PlaceTiles
    LDA #$FFFF
    STA StripeQueue,x
    TXA
    STA StripeIndex
..SingleSide:
    PLB
    bank auto

; Initialise next state
    SEP #$30
    INC MessageState
    INC MessageState
    STZ MessageTimer
    LDA #$20                ; Display layer 3
    STA MirW34SEL           ;
    LDY #$82                ; Disables mainscreen inside the mask...
    LDA MirTM               ; ... but only if layer 3 is on subscreen
    AND #$04                ;
    BEQ +                   ;
    LDY #$22                ; Disable subscreen instead.
+   STY MirCGWSEL           ; Handles both colour maths and subscreen layer 3.
    LDX #$00                ;
    LDA GameTranslevel      ; Check for switch palace levels.
    CMP YellowSwitchPalace
    BEQ ..SwitchMessage
    INX
    CMP BlueSwitchPalace
    BEQ ..SwitchMessage
    INX
    CMP RedSwitchPalace
    BEQ ..SwitchMessage
    INX
    CMP GreenSwitchPalace
    BNE .WaitForNMI
..SwitchMessage
    INX
    STX SwitchColour        ; Mark message as Switch Palace message (affects !-blocks on the overworld)
if !EnableSwitchPalace
    LDA #$20                ; Don't mask out sprites.
    STA MirWOBJSEL
    JMP DrawExclamationBlocks
endif

; Do nothing until the NMI code has finished
; (either the tilemap is backed up or restored, a process which takes two frames).
; This will break if NMI doesn't fire, though, but this only happens in exceptional cases
; (and you also have greater problems too when that happens).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.WaitForNMI:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RTS


; When the message is visible: Keep it enabled until the player presses ABXY, Start or Select
; or, in case of intro / switch palace the time runs out.
; If the message closes, also make the
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.WaitForPlayer:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    LDA GameLevelOverride
    ORA SwitchColour
    BEQ ..NotSpecial
    LDA MessageWait
    BEQ ..NotSpecial
    LDA GameFramecounterA
    AND #$03
    BNE ..Return
    DEC MessageWait
    BNE ..Return
    LDA SwitchColour
    BEQ ..NotSpecial
    INC OverworldEventFlag
    LDA #$01
    STA LevelMidwayPoint

..ToOverworld:
    STA OverworldAction
    LDA #$0B
    STA GameMode
RTS

..NotSpecial:
if !AutomaticIntro
    LDA GameLevelOverride
    BNE ..IntroMessage
    LDA ControllerBPressed
    AND #$C0
    ORA ControllerAPressed
    AND #$F0
    BEQ ..Return
    BRA ..CloseMessage

..IntroMessage
else
    LDA ControllerBPressed
    AND #$C0
    ORA ControllerAPressed
    AND #$F0
    BEQ ..Return
    LDA GameLevelOverride
    BEQ ..CloseMessage
endif
    ;LDA #$8E
    ;STA $1F19|!addr
    LDA #$00
    STA GameLevelOverride
BRA ..ToOverworld

..CloseMessage
    LDA #$22                ; Disable layer 3 and subscreen again
    STA MirW34SEL
    ;LDA #$22
    STA MirCGWSEL
    LDA MessageState
    INC #2
    STA MessageState
..Return:
RTS


; Close the message with a similar routine and disables both the message
; and the HDMA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Shrink:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    LDA MessageTimer
    SEC : SBC #$04
    STA MessageTimer
    BNE GenerateWindow      ; Not quite stable in that it expects the subroutines to be inserted right after the main code
    STZ MessageNumber
    STZ MessageState
    LDA.b #1<<!WindowHdmaChannel
    TRB MirHDMAEN
RTS
