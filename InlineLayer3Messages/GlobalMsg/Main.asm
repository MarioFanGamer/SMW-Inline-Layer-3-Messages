includefrom "InlineLayer3Messages"

!CurrentMessageID = $10000

incsrc "../Messages.asm"

if !CurrentMessageID < $10000
    error "Message !CurrentMessageID is missing its terminator."
endif

!GlobalMessage_Count = 0
!GlobalMessage_SkippedMsg = 0

GlobalMessagePointers:
for i = 0..!GlobalMessage_LargestID+1
    if defined("GlobalMessage_!{i}_label")
        dw !{GlobalMessage_!{i}_label}
        !GlobalMessage_Count #= !GlobalMessage_Count+1
    else
        dw $0000
        !GlobalMessage_SkippedMsg #= !GlobalMessage_SkippedMsg+1
    endif
endfor

print " ",dec(!GlobalMessage_Count)," global messages have been inserted"

if !GlobalMessage_SkippedMsg > 0
    print " ",dec(!GlobalMessage_SkippedMsg)," global message numbers have been skipped"
endif

undef "CurrentMessageID"
