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
; Read the readme for more information.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Patch setups
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

asar 1.90

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

incsrc "InlineLayer3Messages/Settings.asm"

incsrc "InlineLayer3Messages/Core/Defines.asm"

if !FixRetry && !GlobalMessages
    print " Total amount of custom global messages limited to four messages."
    !GlobalMessages = 0
endif

if not(!FastNmi)
    warn "\!FastNmi has been disabled. It's recommend to have this enable to reduce black bars / HDMA messing up when a message (dis)appears."
endif

freecode
if !GlobalMessages
prot GlobalMessageSystem
endif

incsrc "InlineLayer3Messages/Core/Hijacks.asm"
incsrc "InlineLayer3Messages/Core/Main.asm"
incsrc "InlineLayer3Messages/Core/Subroutines.asm"
if !HijackNmi
incsrc "InlineLayer3Messages/Core/Nmi.asm"
endif

if !GlobalMessages

freedata

incsrc "InlineLayer3Messages/GlobalMsg/Macros.asm"
incsrc "InlineLayer3Messages/GlobalMsg/Characters.asm"
incsrc "InlineLayer3Messages/GlobalMsg/Main.asm"

endif

print "--------------------------------"
print "Freespace used: ",freespaceuse," bytes"

