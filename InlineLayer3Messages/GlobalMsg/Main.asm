includefrom "InlineLayer3Messages"

incsrc "Macros.asm"
incsrc "Characters.asm"

!CurrentMessageID = $10000

incsrc "../Messages.asm"

if !CurrentMessageID < $10000
    error "Message !CurrentMessageID is missing its terminator."
endif

!GlobalMessage_SkippedMsg = 0

GlobalMessagePointers:
for i = 0..!GlobalMessage_LargestID
    if defined("GlobalMessage_!i")
        dw GlobalMessage_!i
    else
        dw $0000
        !GlobalMessage_SkippedMsg #= !GlobalMessage_SkippedMsg+1
    endif
endfor

if !GlobalMessage_SkippedMsg > 0
    print " ",dec(!GlobalMessage_SkippedMsg)," have been skipped"
endif

undef "CurrentMessageID"
