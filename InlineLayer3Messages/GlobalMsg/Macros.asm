include

; Some temporary defines used by global messages
!GlobalMessage_LargestID = $00

; Defines a global message
; Partially based of VWF Dialogues but simplified due to the lack of need to define a message header
macro GlobalMessageStart(id)

if <id> >= !GlobalMessage_MaxMessages
    error "Message id is too large."
endif
if !CurrentMessageID < $10000
    error "Message !CurrentMessageID must first be terminated before loading a new one."
endif

!CurrentMessageName = "GlobalMessage<id>"
!CurrentMessageID = $<id>

if !CurrentMessageID > !GlobalMessage_LargestID
    !GlobalMessage_LargestID #= !CurrentMessageID
endif

!temp_message_id #= !CurrentMessageID

!{GlobalMessage_!{temp_message_id}_label} := !CurrentMessageName

!GlobalMessagePos #= pc()

!{GlobalMessage_!{temp_message_id}_label}:

undef "temp_message_id"
endmacro

; Finishes a global message
; It's main purpose is to read how many bytes have been loaded
; and potentially warn the player for any excess data
macro GlobalMessageEnd()
if !CurrentMessageID >= $10000
    error "Message !CurrentMessageID is missing its terminator."
endif

!GlobalMessageLen #= pc()-!GlobalMessagePos

print "Message !CurrentMessageID length: $",hex(!GlobalMessageLen)," bytes"

; Check the message length.
; If less than 90 characters, place a terminator at the end
; If more than 90 characters, throw a warning towards the user that the message is longer than expected (patch still inserts fine as it is).
if !GlobalMessageLen < $90
    db !MessageTerminator
elseif !GlobalMessageLen > $90
    warn "Message !CurrentMessageID has more than 144 characters (8 rows, 18 columns)."
endif

; Clean up message states
!CurrentMessageID = $10000
undef "GlobalMessagePos"

endmacro
