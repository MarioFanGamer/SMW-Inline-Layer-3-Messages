; Sample message
%GlobalMessageStart(00)

db "This  is  a global"
db "message.          "
db "Global    messages"
db "are defined within"
db "the    patch   but"
db "otherwise function"
db "like  Lunar  Magic"
db "messages.    Also,"
db "this   message  is"
db "clearly  too  long"
db "and won't fit into"
db "a    single    SMW"
db "message at all.   "


%GlobalMessageEnd()

%GlobalMessageStart(01)

db "                  "
db "   Way too short  "
db "  global message"

%GlobalMessageEnd()

%GlobalMessageStart(02)

db "-POINT OF ADVICE- "
db "You  can use Lunar"
db "Magic  to generate"
db "justified messages"
db "(each  row  has  a"
db "fixed width, there"
db "is   no  space  at"
db "either edge).     "

%GlobalMessageEnd()
