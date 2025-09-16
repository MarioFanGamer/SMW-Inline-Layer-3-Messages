;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Inline Layer 3 Messages
;   by MarioFanGamer
;
; The way vanilla messages work is that they're drawn in
; the same place in the tilemap and layer 3 gets moved to
; this position. This makes it incompatible with layer 3
; tilemaps by default so both shouldn't be used at the
; same time.
; This patch on the other hand, inspired and partially
; based of Yoshi's Island, writes a message with the
; current position of layer 3 in mind i.e. the layer 3
; position is unchanged and the message will move with
; the tilemap instead, making it compatible with most
; types of layer 3 backgrounds.
;
; Read the readme for more information
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This file is the main insertion file and includes all
; the user settings necessary to modify this patch.
; The actual patch is found inside the folder
; "InlineLayer3Messages" which mostly consists of interal
; files since keeping them in one single file is too
; complex and naturally shouldn't be edited by you, the
; user.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; User defines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM defines

; These are just vanilla defines but if you know what you're doing, you can change them as well.
!MessageNumber	= $1426|!addr	; The message number
!MessageState	= $1B88|!addr	; Which state the game is currently in.
!MessageTimer	= $1B89|!addr	; Same as in the vanilla game: Controls the box's size and when to change the state but also which side to write
!MessageWait	= $1DF5|!addr	; How long the player must wait before the intro or a switch palace message can be dismissed

; These can stay in WRAM because code is handled by SNES
!MessageBuff	= $7FC700		; (144 bytes) Writes the message into a buffer, 8 lines, 18 rows
!Layer3Buff     = $7FA600		; (1024 bytes) We want to restore 8 lines of 64 tiles, two bytes each tile

; Message defines

!TextPage = 1					; 0-3: Which page to read the tiles
!TextPalette = $6				; 0-7: The palette for all tiles
!TextPriority = 0				; 0-1: The priority (should be always 1)
!TextXFlip = 0	    			; 0-1: Whether the characters are horizontally mirrored
!TextYFlip = 0  				; 0-1: Whether the characters are vertically mirrored

!EmptyTile = $1F				; The tile to draw for the border or reminder of the text.

; Other defines
!EnableSwitchPalace = 1			; If set to 1: Display dotted and exclamation mark blocks on switch palace messages.
!HijackNmi = 1					; If set to 1: Handle NMI code with this patch (requires UberASM if disabled).
!NmiFixRetry = 1				; If set to 1: Fixes incompatibilities with Retry when using the NMI hijack.
!FastNmi = 1                    ; If set to 1: Uses two bytes of freeRAM to reduce calculations with message position in tilemap
!AutomaticIntro = 0				; If set to 1: Don't wait for player input in the intro.
!GlobalMessages = 0             ; If set to 1: Enable the use of global messages.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Patch setups
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	; SA-1 base addresses
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
else
	; Non SA-1 base addresses
    lorom
	!sa1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
endif


dpbase !dp
optimize dp always
optimize address mirrors

print "Inline Layer 3 Messages"
print " by MarioFanGamer"
print "--------------------------------"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Include stuff
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc "InlineLayer3Messages/Defines.asm"

freecode
if !GlobalMessages
prot GlobalMessageSystem
endif

incsrc "InlineLayer3Messages/Core/Main.asm"

if !GlobalMessages

freedata

incsrc "InlineLayer3Messages/GlobalMsg/Main.asm"

endif

print "--------------------------------"
print "Freespace used: ",freespaceuse," bytes"

