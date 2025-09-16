; RAM defines

; These are just vanilla defines but if you know what you're doing, you can change them as well.
!MessageNumber	= $1426|!addr	; The message number
!MessageState	= $1B88|!addr	; Which state the game is currently in.
!MessageTimer	= $1B89|!addr	; Same as in the vanilla game: Controls the box's size and when to change the state but also which side to write
!MessageWait	= $1DF5|!addr	; How long the player must wait before the intro or a switch palace can be dismissed

; These can stay in WRAM because code is handled by SNES
!MessageBuff	= $7FC700		; 18 * 8 = 144 bytes

; Message defines

!TextPage = 1					; Which page to read the tiles
!TextPalette = $6				; The text's properties.
!TextPriority = $39				; The text's properties.
!TextXFlip = $39				; The text's properties.
!TextYFlip = $39				; The text's properties.

!EmptyTile = $1F				; The tile to draw for the border or reminder of the text.

; Other defines
!EnableSwitchPalace = 1			; If set to 1: Display dotted and exclamation mark blocks on switch palace messages.
!HijackNmi = 0					; If set to 1: Handle NMI code with this patch (requires UberASM if disabled).
!AutomaticIntro = 0				; If set to 1: Don't wait for player input in the intro.
!GlobalMessages = 0             ; If set to 1: Enable the use of global messages.
