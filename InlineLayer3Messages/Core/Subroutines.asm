includefrom "InlineLayer3Messages"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Inline Layer 3 Messages subroutines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Contains all the important and (common) routines outside
; the main code.
;
; Due to some quirks / optimisations in the main code,
; this MUST be inserted immediately after the main code.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Generates a window
; This is different from the original SMW code in that the windowing position
; is relative to the layer BG3 position (more specifically, the position within a single tile
; to keep it aligned with the tilemap).
; Uses:
;   $00 (8-bit): Window centre X position
;   $01 (16-bit): Pointer to lower half of the windowing table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GenerateWindow:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print " GenerateWindow subroutine: $",pc

    ; Get centre of message
    LDA MirBG3XOFS
    AND #$07
    CMP #$04
    BCS +
    ORA #$08
+   EOR #$FF
    INC
    CLC : ADC #$88          ; 0x80 + 8
    STA $00
    REP #$20
    
    ; Get table pointer
    LDA MirBG3YOFS
    AND #$0007
    CMP #$0004
    BCS +
    ORA #$0008
+   EOR #$FFFF
    INC
    CLC : ADC #$005F        ; 0x58 + 8 - 1

    ASL                     ; Windowing table is made of words (left edge + right edge).
    TAX                     ; Top half, goes from bottom to top.
    DEX                     ; Fix offset
    DEX
    CLC : ADC.w #WindowBuffer
    STA $01                 ; Indirect because Y is also the loop count.

    ; Get edges
    SEP #$20
    LDA $00
    DEC
    CLC : ADC MessageTimer
    XBA
    LDA $00
    SEC : SBC MessageTimer
    REP #$20

    LDY #$00
.Loop:
    CPY MessageTimer        ;
    BCC .NoWindow           ; If outside the box...
    LDA #$00FF              ; Disable window.
.NoWindow:
    STA WindowBuffer,x
    STA ($01),y
    DEX
    DEX
    INY
    INY
    CPY #$50
    BNE .Loop
    SEP #$20

    LDA.b #1<<!WindowHdmaChannel
    TSB MirHDMAEN
RTS


; Draws !-blocks on the message similar to the original code,
; albeit with BG3 relative positions.
; Like the window itself, this depends primarily on the layer 3 position,
; although this also takes the block colour as an additional input.
; Inputs:
;   X: !-block colour index
; Uses:
;   $00 (8-bit): Left !-block screen X position
;   $01 (8-bit): Left !-block screen Y position
if !EnableSwitchPalace
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawExclamationBlocks:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print " DrawExclamationBlocks subroutine: $",pc

    TXA
    ASL #4
    TAX
    LDA MirBG3XOFS
    AND #$07
    CMP #$04
    BCS +
    ORA #$08
+   EOR #$FF
    ;INC : CLC
    SEC : ADC #$58          ; 0x48 + 8
    STA $00
    LDA MirBG3YOFS
    AND #$07
    CMP #$04
    BCS +
    ORA #$08
+   EOR #$FF
    ;INC : CLC
    SEC : ADC #$5F          ; 0x48 + 8 - 1
    STA $01
    REP #$20
    LDY #$1C
.Loop
    LDA ExclamationMarkTiles-16,x
    STA $0202|!addr,y
    PHX
    TXA
    AND #$000F
    TAX
    LDA ExclamationMarkOffsets,x
    CLC : ADC $00
    STA $0200|!addr,y
    PLX
    INX #2
    DEY #4
    BPL .Loop
    STZ $0400|!addr
    SEP #$20
RTS
endif


; Draws the message tiles to tilemap
; Note that this expects the bank to be that of
; the message source since it's 16-bit.
; It may actually be faster to have the DB at
; the stripe bank but since this runs and use
; a 24-bit pointer for the message source instead
; (or use X for the message and pointers+Y for stripe
; instead), but since this code only runs at two
; frames at most when everything is paused, the
; effort isn't really worth it.
; Input:
;   $00 (16-bit): Leftmost VRAM address
;   $02 (16-bit): Total columns to place
;   $04 (16-bit): Message pointer (high byte in DB)
;   $06 (16-bit): Which side to place.
; Uses:
;   $08 (16-bit): VRAM address in use
;   $0A (16-bit): Row count
;   $0C (16-bit): Loop count (columns)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlaceTiles:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print " PlaceTiles subroutine: $",pc

    LDA #$0009              ; 10 rows
    STA $0A
    LDA $00
    STA $08
.Loop:
    LDA $08
    XBA
    STA StripeQueue,x
    LDA $02                 ; Columns in total to place
    STA $0C
    ASL
    DEC
    XBA
    STA StripeQueue+2,x
    INX #4
    
    ; Check if it's the top or bottom most row.
    ; I know that RLE is smaller but it doesn't appear to upload faster
    ; than having it all decompressed.
    ; Really, all I'm doing is to take up more RAM which is only used up
    ; for a single frame (and it also makes adding corner tiles easier).
    LDA $0A
    BEQ .EmptyTiles
    CMP #$0009
    BNE .PlaceText
.EmptyTiles:
    LDA.w #!TextProp<<8|!EmptyTile
    STA StripeQueue,x
    INX #2
    DEC $0C
    BNE .EmptyTiles

; Increment the VRAM address
; Keep in mind to switch the tilemap. As such, increment the Y-position individually
; before you ORA it with the rest of the VRAM address without the Y position.
.Shared:
    LDA $08
    PHA
    AND #$0BE0          ; Get Y position only
    ORA #$0400          ; Carry over on overflow.
    CLC : ADC #$0020
    AND #$0BE0
    STA $08
    PLA
    AND #~$0BE0
    ORA $08
    STA $08
    DEC $0A
    BPL .Loop
RTS

; This is complex:
; I have no trouble to place the text but it makes a difference to also consider the border.
; The solution: If it's the left half, place the border, decrement the column counter
; and then place the text.
; If it's the right half, place the text at first and then overwrite the column with the border tile.
; Do the same with the left half if the full box is drawn
.PlaceText:
    LDY #$0000          ; Set the message pointer to 0.
    LDA $06
    BNE ..PlaceTextLoop
    LDA.w #!TextProp<<8|!EmptyTile
    STA StripeQueue,x
    INX #2
    DEC $0C
    BEQ ..PlaceTextFinish
    
..PlaceTextLoop:
    LDA ($04),y         ; Get text
    AND #$00FF          ; (8-bit values only)
    ORA.w #!TextProp<<8 ; Add in the properties.
    STA StripeQueue,x
    INX #2
    INY
    DEC $0C
    BNE ..PlaceTextLoop
    
..PlaceTextFinish:
    LDA $06             ; If it's the right side, always place a border tile
    BNE ..RightSide     ;
    LDA $02             ; Otherwise only if the full box is drawn.
    CMP #$0014
    BNE ..NotFullBox
..RightSide:
    LDA.w #!TextProp<<8|!EmptyTile
    STA StripeQueue-2,x ; Write to previous tile.
..NotFullBox:
    LDA $04             ; Load the next row of text.
    CLC : ADC #$0012
    STA $04
JMP .Shared
