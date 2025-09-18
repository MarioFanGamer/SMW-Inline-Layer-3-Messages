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
; Read the readme for more information unrelated to these
; defines.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM defines

; These are just vanilla defines but if you know what you're doing, you can change them as well.
!MessageNumber      = $1426|!addr   ; The message number (and also whether to display a message at all)
!MessageState       = $1B88|!addr   ; Which state the game is currently in.
!MessageTimer       = $1B89|!addr   ; Same as in the vanilla game: Controls the box's size and when to change the state but also which side to write
!MessageWait        = $1DF5|!addr   ; How long the player must wait before the intro or a switch palace message can be dismissed

; Actual free RAM
!MessageVram        = $18C5|!addr   ; (2 bytes) Calculates the VRAM position one for faster code (only used if !FastNmi is set to 1)

; These can stay in WRAM because code is handled by SNES
!MessageBuff        = $7FC700       ; (144 bytes) Writes the message into a buffer
!Layer3Buff         = $7FAC90       ; (1024 bytes) Tiles

; Message defines

!TextPage           = 1             ; 0-3: Which page to read the tiles
!TextPalette        = $6            ; 0-7: The palette for all tiles
!TextPriority       = 0             ; 0-1: The priority (should be always 1)
!TextXFlip          = 0             ; 0-1: Whether the characters are horizontally mirrored
!TextYFlip          = 0             ; 0-1: Whether the characters are vertically mirrored

!EmptyTile          = $1F           ; The tile to draw for the border or reminder of the text.

; Other defines
!EnableSwitchPalace = 1             ; If set to 1: Display dotted and exclamation mark blocks on switch palace messages.
!HijackNmi          = 1             ; If set to 1: Handle NMI code with this patch (requires UberASM if disabled).
!NmiFixRetry        = 1             ; If set to 1: Fixes incompatibilities with Retry when using the NMI hijack.
!FastNmi            = 1             ; If set to 1: Uses two bytes of freeRAM to reduce calculations with message position in tilemap
!AutomaticIntro     = 0             ; If set to 1: Don't wait for player input in the intro.
!GlobalMessages     = 0             ; If set to 1: Enable the use of global messages.
