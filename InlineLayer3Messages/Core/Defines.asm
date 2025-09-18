include

; Misc defines
function GetYXPCCCTT(char, pal, prio, xflip, yflip) = \
         ((char&$300)>>8)\
        |((pal&$7)<<2)\
        |(select(prio, 32, 0))\
        |(select(xflip, 64, 0))\
        |(select(yflip, 128, 0))

!TextProp #= GetYXPCCCTT(!TextPage<<8, !TextPalette, !TextPriority, !TextXFlip, !TextYFlip)

; RAM labels

MirBG3XOFS = $000022|!dp
MirBG3YOFS = $000024|!dp
MirW12SEL = $000041|!dp
MirW34SEL = $000042|!dp
MirWOBJSEL = $000043|!dp
MirCGWSEL = $000044|!dp

MirHDMAEN = $000D9F|!addr

MirTM = $000D9D|!addr

ControllerAHeld = $000015|!dp
ControllerAPressed = $000016|!dp
ControllerBHeld = $000017|!dp
ControllerBPressed = $000018|!dp

GameFramecounterA = $13
GameMode = $000100|!addr
GameTranslevel = $0013BF|!addr
GameLevelOverride = $000109|!addr

LevelMidwayPoint = $0013CE|!addr

OverworldAction = $000DD5|!addr
OverworldEventFlag = $001DE9|!addr

MessageNumber = !MessageNumber
MessageState = !MessageState
MessageTimer = !MessageTimer
MessageBuffer = !MessageBuff
MessageWait = !MessageWait
MessageVram = !MessageVram

Bg3Buffer = !Layer3Buff

WindowBuffer = $0004A0|!addr

PlayerOnYoshi = $00187A|!addr

SwitchColour = $0013D2|!addr

StripeIndex = $7F837B
StripeQueue = $7F837D

; Lunar Magic's message hack
; Ideally, I'd use constants but Lunar Magic makes that a bit difficult
; Nothing stops you from modifying the patch to do so but at the end,
; this isn't very user-friendly.

YoshisHouseLevel = $03BB9B|!bank
YellowSwitchPalace = $03BBA2|!bank
BlueSwitchPalace = $03BBA7|!bank
RedSwitchPalace = $03BBAC|!bank
GreenSwitchPalace = $03BBB1|!bank
MessageIndex = $03BE80|!bank
MessageTable = $03BC0B|!bank


; Exclamation mark blocks in switch message

ExclamationMarkTiles = $05B29B|!bank
ExclamationMarkOffsets = $05B2DB|!bank

; Internal constants

!Layer3Tilemap = $5000
!MessageTerminator = $FE
!GlobalMessage_MaxMessages = $FC

!WindowHdmaChannel #= (read1($0092D7+1)&$F0)
