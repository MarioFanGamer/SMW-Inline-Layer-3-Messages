pushpc

org $05B10C
autoclean JML NewMessageSystem

; Make the table relative offsets only
org ExclamationMarkOffsets
db $00,$00,$08,$00,$00,$08,$08,$08
db $40,$00,$48,$00,$40,$08,$48,$08

if !HijackNmi

org $00820D
JML HijackNmi

else

if read3($00820D)&$1FFFFF != $143AAD
print " Revert NMI hijack."
org $00820D
    LDA $143A|!addr
    BEQ $05
endif

endif

pullpc
