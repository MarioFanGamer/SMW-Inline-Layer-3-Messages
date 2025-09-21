                  Inline Layer 3 Messages v1.1
                        by MarioFanGamer
                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What does this patch do?
----------------------------------------------------------
That one makes a rather radical change to SMW's messages:
They don't remove the layer 3 tilemap. Instead, messages
are placed as centred as possible to the camera and
restore layer 3 when closed.
This allows you to use "vanilla" messages alongside a
layer 3 image.

What are the advantages to other layer 3 preserving
messages?
----------------------------------------------------------
The most important point is that the patch is still a
layer 3 tilemap and reuses SMW's messages. As a result,
you still can use Lunar Magic to write messages unlike
e.g. VWF Dialoguess or bg4vwf which requires you to
repatch them each time you want to add a new message.
It also is far simpler than Sprite Message Box, requiring
only 1424 bytes of freeRAM (SSB uses 4096 for the decomp
buffer alone) and doesn't take care of finding unused OAM
slots and graphics.
In case of limitations, you might want to use the other
patches.

There's a whole folder of files!
----------------------------------------------------------
The patch is fairly complex and with so many changes, you
do lose an overview for all the stuff. Fortunately, most
of it is irreleavant and the only releavnt user file is
the patch file "InlineLayer3Message.asm" as well as
"Messages.asm" inside "InlineLayer3Messages/GlobalMsg".

The former is the main patch file, the file you insert
with Asar. It contains all the user customisations needed
which is safe to do as such. There are more defines used
in the patch but they're only interesting for technical
users.
The latter is the message file for global messages, only
used when global messages are.

Lastly, there is the good ol' UberASM folder. This
contains the NMI code, the code which backs up the
tilemap.
It should only be inserted if you have "!HijackNmi"
disabled, though, because doing so means doing work twice
which wastes v-blank (and GUARANTEES black bars to
appear).

How do I use global messages?
----------------------------------------------------------
Let's ask an easier question first.

Any rules I need to take care for free RAM?
----------------------------------------------------------
Basically, some should be in shadow RAM, the other should
be in WRAM only.

The first four message defines is the RAM used by the
vanilla system and doesn't NEED to be changed (although
nothing stops you from doing so, of course) so you
can't really call these freeRAM defines.

What is freeRAM, though, is "!MessageVram", a variable
which preserves the VRAM destination for the message for
faster code (particularly important because some of it
runs in v-blank, the period where the screen can be
updated). It needs to be two bytes (VRAM is a 16-bit
address) and preferably be in shadow WRAM (the
$0000-$1FFF range) and needs to be attached with a
"|!addr" for full SA-1 compatibility.
This is only used when "!FastNmi" is enabled (and I
recommend this due to the aforementioned v-blank
limitation).

"!MessageBuff" is the message buffer and contains the
message itself. It's 144 bytes large (8 rows, 18 columns)
and contains the final message since it can be compressed
in the ROM.
This variable is recommend to be in WRAM ($7E0000-$7FFFFF)
even if you use SA-1 because neither code in the patch is
processed by SA-1 (basically, changing it to banks $40/$41
is a waste of the more limited BW-RAM).

"!Layer3Buff" is the buffered part of the layer 3 tilemap,
the rows were the message get overwritten. This one
requires you to reserve 1280 bytes of RAM (2 bytes/tile *
64 tiles/per * 10 rows)
This variable is recommend to be in WRAM even if you use
SA-1 because it's only needed for v-blank code which
can't run in SA-1.

It should be noted that this RAM is only needed when a
message runs so if you can make sure you won't
(accidentally) trigger a message, you can use these as
freeRAM in other places (e.g. using it as an HDMA table,
especially with HDMA which can't work with messages
anyway).

So... how do I use global messages in the first place?
----------------------------------------------------------
You first need to enable it (this is an exercise for you,
the user on where to figure it out).

Once you've done that, you can define global messages
however you want. They're found in the aforementioned
"Messages.asm" file and the way it works is that a message
consists of three parts: The initialiser, the message
itself and the terminator. Altogether, a message
generally looks like this:

%GlobalMessageStart(nn)

db "------------------"
db "------------------"
db "------------------"
db "------------------"
db "------------------"
db "------------------"
db "------------------"
db "------------------"

%GlobalMessageEnd()

Here is each function in detail:
- %GlobalMessageStart(nn) is the message initialiser.
  All it does is to set the message label by the given
  value specified in nn (values are in hex but without
  the '$' so 0A is valid but $42 isn't). By default,
  the valid range is 00-FB.
- %GlobalMessageEnd() is the terminator. It controls the
  result and automatically places the terminator if there
  are fewer than 144 characters but also warn you, the
  user should there be more than 144 characters in a
  single message.
- The "db" lines is the message itself. A single message
  consists of 144 characters, split over 8 lines with 18
  characters each. Line breaks are handled by the game
  itself so having more or fewer characters then
  specified *will* break the message structure.
  You can also enter the character values directly for
  special characters like Yoshi's pawprint.
  In order to do this, stop the string with a quote '"',
  add a comma, and write the character number directly
  (remember: Without '$' = decimal, with '$' = hex).
  You can write consecutive numbers separated by comma and
  restart a string with a comma and then quote.
  In other words, it should look something like this:
  "...",$42,$13,$37,"..."
  For example, the last line of Yoshi's message in
  Yoshi's House looks like this in Lunar Magic:
  "         - Yoshi\62\63"
  For the patch, the equivalent is this:
  "         - Yoshi",$62,$63

To call a global message, write the $nn+4 value to
!MessageState in a different code (e.g. a custom info
box).
One vanilla method is to stack multiple level message
comands on top of each other which increment the
message number by one each but other then that, you need
to use custom code to call these messages.
The reason it's +4 is because 0 is no message (although
you could make changes to SMW so that !MessageState is
the message trigger, leaving !MessageNumber purely as
the message to display), 1 is the first level message,
2 is the second level message and 3 the Yoshi hatching
message (arguably the ORIGINAL global message), leaving
4 as the first free number for custom messages.
This system is familiar to any user of BG4VWF where
global messages are called in a similar way (though this
patch still handles Yoshi like vanilla due to LM message
compatibility).

I can't use the patch!
----------------------------------------------------------
I can think of two causes:
 - You didn't put in the "InlineLayer3Messages" folder
   in the same folder as "InlineLayer3Message.asm" or
 - you didn't save a message in Lunar Magic at least once.

Who can read error messages has got a clear advantage.
Any known incompatibilities?
----------------------------------------------------------
Obviously layer 3 tilemaps are now usable. Only if the
tilemap uses tiles from the top half of page 2 is where
you might get into trouble but these can be remapped.
Regarding vanilla SMW? I made sure to add all
functionalities, from the Yoshi's House message to Switch
Palace messages, although strictly speaking, this only
applies to SMW edited by Lunar Magic.
It is possible to modify the original code but the
advantages thereof are limited since most people use
Lunar Magic.

I even made sure it also works with colour addition (that
includes the ghost house mist as well as level modes 1E
and 1F) but colour subtraction with layer 3 on subscreen
is unfortunatelly difficult to solve
(it requires layer 3 to be on mainscreen but SMW by
default doesn't use the main/subscreen mirrors to easily
handle that, alongside separate mirros for windowing on
main and subscreeen).

HDMA, depends: Layer 3 position? Can be forgotten
immediately. Windowing? Since the message still uses
windowing, they should be avoided as well. Anything else
(including what is commonly understood as HDMA i.e.
colour gradients) still works.

Retry? I've tested this and as far as I know, it's
definitively functional, although you should set
"!FixRetry" in the user settings.
The biggest limitation of retry are global messages. The
way Retry works is that it uses message numbers to
determine its state as well as whether a retry prompt
appears rather than.
Fortunately, Retry only reserves from message 0x08 onwards
which translates to four global messages.

(This also is one of the reasons why the NMI code
originally wasn't as optimised as it could be because
I need two bytes of freeRAM to preserve the VRAM
position.)

Message box patches should be generally avoided because
my patch writes messages differently than these patches
do. This includes patches which modify the intro message
(such as automatic intro dismiss but that is something
I also have included as an option for this very reason).
This doesn't mean you can't use patches which add
another message system (such as VWF Dialogues) on top,
they just can't replace vanilla messages.

Can I use the goal with layer 3 backgrounds as well?
----------------------------------------------------------
Sadly not because the goal can't be easily put inline
(not to mention I'd create another patch for that).

The message box glitches for one frame!
----------------------------------------------------------
It's... an unfortunate limitation but this has to do with
how unoptimised SMW's stripe image routine is. 10 writes
on a single scanline is certainly much for SMW (same
reason why the background might glitch if you enable a
32x32 block and have HDMA active), though the main fault
lies on Lunar Magic and its VRAM remapper which runs way
too much code in v-blank.
I'd say it's a necessary tradeoff without making the patch
any more complex that it currently is.

That being said, there are two ways to mitigate this:
- Use FastROM. With it, the code runs slightly faster,
  thus getting the code to be in v-blank. Does not work
  with SA-1 applied.
- Apply Kevin's Stripe Image Optimizer to your ROM. This
  one applies to changes of the VRAM remapper to outside
  of v-blank.

There are many other ways to reduce the issues such as
disabling the Status Bar (as the demo does) but these
do affect the game itself.

What about the BPS?
----------------------------------------------------------
That's just a test ROM showing various application within
the vanilla game (excluding custom layer 3 backgrounds,
of course).

Oh, and give credits to allowiscous, imamelia, Berk and
Link13 for layer 3 conversions for some of SMW's
layer 2 backgrounds, Sonikku for the custom info box and
Lui for Disable Status Bar!

I don't want to play through the first level of the demo
again!
----------------------------------------------------------
You can use start+select to exit out of the level and
beat it that way. The ability is only active for the first
level, though.

Do I must give you credits?
----------------------------------------------------------
Appreciable but not necessary.

But... but... The license!
----------------------------------------------------------
This only applies if you distribute the source code,
intended for when you modify this patch and want to merge
the code back to the repo or take code FROM it and create
your own public patch with it.
This is different to most other BSD licenses (BSD0 as the
notable exception which is basically PB) which require
attribution/license inclusion even for binary
distributions which is overkill for SMW hacking.

tl;dr Don't mind this for non-code products.

Why did you make this patch?
----------------------------------------------------------
Curiosity in how Yoshi's Island handles its messages, of
which part of the patch's code is based of, since it also
uses message boxes in levels with layer 3 images.

I've got a question!
----------------------------------------------------------
Post it to the forums. In the worst case, you can PM me.

Is that really all?
----------------------------------------------------------
It could very likely be that v-blank overflows which
yields the message to be in a glitched state for one frame.
Using a less heavy status bar (such as DKCR Status Bar or
disable it outright, see the demo ROM) can fix it, though
I have included a patch which disables the vanilla status
bar if a message is active (no such luck for custom status
bars, you have to do it on your own) if a message is
active. Even then, it won't fix the issue altogether but
it does make it appear less likely. The alternative is to
use a stripe image optimiser.

Changelog
----------------------------------------------------------
1.0:
 - Initial release

1.0.1:
 - Fixed !-blocks in switch palace messages from not
   getting display properly.
 - Clarified that Retry is incompatible with this patch.
 - Added SA-1 Pack v1.35+ compatibility (the one which
   remaps DMA).
 - Fixed some spelling errors.

1.1.0:
 - Fixed errors appearing in FastROM
 - Fixed ejected !-blocks being always yellow when the
   !-blocks in messages are disabled.
 - Fixed incompatibility with Peach cutscene when using NMI code through UberASM
 - Added global messages
