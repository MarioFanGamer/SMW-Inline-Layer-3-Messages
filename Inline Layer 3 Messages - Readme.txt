                     Inline Layer 3 Messages
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

Why two ASM files?
----------------------------------------------------------
I have separated the main and NMI code in case you want to
insert the latter separately. In case you don't know, NMI
is an interrupt (i.e. the current code is halted) which
the SNES triggers at the start of v-blank. V-blank is the
period where you can update the screen including writing
to the tilemap.
NMI code has got the issue that the places to hijack is
limited which is why I preferably want to use UberASM
instead of putting it together with the main patch. The
insertion gets more complicated that way, though. You can
disable the insertion of the NMI code with !HijackNmi and
insert InlineMessageNmi.asm with UberASM for the NMI code
for either game mode 14 or all the levels you want to use
the a message. Use only one insertion method, though!

Altogether, InlineLayer3Message.asm should always be
patched with Asar, InlineMessageNmi.asm is either
automatically inserted with the patch or inserted with
UberASM depending on the patch's configuration.

I can't use the patch!
----------------------------------------------------------
I can think of two causes:
 - You didn't put InlineMessageNmi.asm in the same folder
   as InlineLayer3Message.asm and have the NMI code
   enabled or
 - you didn't save a message in Lunar Magic at least once.

Who can read the error messages has got a clear advantage.

Any known incompatibilities?
----------------------------------------------------------
Obviously layer 3 tilemaps are now usable. Only if the
tilemap uses tiles from the top half of page 2 is where
you might get into trouble but these can be remapped.
Regarding vanilla SMW? I made sure to add all
functionalities, from the Yoshi's House message to Switch
Palace messages.
I even made sure it also works with colour addition (that
includes the ghost house mist as well as level modes 1E
and 1F) but colour subtraction with layer 3 on subscreen
is unfortunatelly impossible to solve.
HDMA depends: Layer 3 position? Can be forgotten
immediately. Windowing? Since the message still uses
windowing, they should be avoided as well. Anything else
(including what is commonly understood as HDMA i.e.
colour gradients) still work.
Retry? There are some complications between Retry and
message box patches. However, I actually planned this
with retry, though you have to enable Retry compatibility
in InlineMessageNmi.asm.
Message box patches should be generally avoided because
my patch writes messages differently than these patches
do. This includes patches which modify the intro message
(such as automatic intro dismiss but that is something
I also have included as an option for this very reason).
This doesn't mean you can't use patches which add
another message system (such as VWF Dialogues), they just
can't replace vanilla messages.

Can I use the goal with layer 3 backgrounds as well?
----------------------------------------------------------
Sadly not because the goal can't be easily put inline
(not to mention I'd create another patch for that).

What about the BPS?
----------------------------------------------------------
That's just a test ROM showing various application within
the vanilla game (excluding custom layer 3 backgrounds,
of course).

Oh, and give credits to allowiscous, imamelia, Berk and
Link13 for layer 3 conversions of some of SMW's
layer 2 backgrounds!

The message box glitches for one frame!
----------------------------------------------------------
It's... an unfortunate limitation but this has to do with
how unoptimised SMW's stripe image routine is. 10 writes
on a single scanline is certainly much for SMW (same
reason why the background might glitch if you enable a
32x32 block and have HDMA active). I'd say it's a
necessary trade off without making the patch any more
complex that it currently is.

Do I must give you credits?
----------------------------------------------------------
Appreciable but not necessary.

Why did you make this patch?
----------------------------------------------------------
Curiosity in how Yoshi's Island, of which part of the
patch's code is based of, since it also uses message
boxes in levels with layer 3 images.

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
use a stripe image optimiser but as of right know, I can't
think of a patch which does that.

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
