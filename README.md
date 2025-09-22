# Inline Layer 3 Messages for Super Mario World

This is a mod for the Super NES game Super Mario World.

The game includes a basic message system which allows the game to draw a messages in a 8x18 box.
Its main limination is that it can't work with BG3, one of the three background layers the SNES
supports, used in SMW primarily for the HUD but also for the occasional backgrounds (e.g.
Donut Plains 2).
The reason for the incompatibility is because the message causes the background to disappear
both because BG3 is moved to the position of the tilemap and because the action is otherwise
destructive to the tilemap.

This patch is a reimplementation for a similar system used in Super Mario World 2: Yoshi's Island
where the message is integrated into the BG3 tilemap and seamlessly restored.

A demo is included to showcase the patch's function in various usecases with BG3, from standard
levels to combinations with addition blending to implementation of special messages (intro,
Yoshi's House, Switch Palace).

Keep in mind that this readme is primarily a *repository* readme, explaining the technical stuff.
The user manual is found under `Inline Layer 3 Messages - Readme`.


## Building the demo
As it is right now, the demo can't be really built. Part of the problem is that Lunar Magic doesn't
allow you to easily export overworld and given that the demo isn't even necessary, I decided to
not provide a build script for it as of now.
I did provide all the necessary files for the levels themselves, though (graphics, custom info box,
messages), but it's also limited in part because it depends on Lunar Magic code which is closed source
and I also haven't provided a code to insert SMW messages into the ROM.
In fact, I may even split the demo into its own repository due to the effort required with an
LM-independent solution.


## Contributing

### Code of conduct
- Be polite, don't insult others
- Any contribution for the main patch will be licensed under the BSD1 license (see [LICENSE](LICENSE) for more information)

### Syntax
- Labels are generally CamelCase, although underscores can be used for namespaces and sublabel access.
- RAM definitions:
  - Unless it's scratch RAM ($00-$0F range), always use labeled RAM addresses
  - Take advantage of Asar's label optimizer, only specify size explicitly for immediate addressing (and typically only when ambiguous).
  - When defining labels, make sure you mention the general usecase first (e.g. `Game`, `Player`) and then the specific use
  - Also label ROM addresses
  - Use defines for indirectly accessible memory like VRAM
- Comments:
  - Always comment functions, particularly what it takes as input, spits out and which temporary memory is used how
  - Also use comments for code blocks
  - Comments for (user) defines should preferably be placed 
  - Keep comments within codes at a minimum, it should be as self-explanatory as possible
  - Keep comments consistently at the same line.
- Indentation:
  - Always use four spaces for indentation, don't use tabs directly.
  - All code is generally indendented once.
  - Return opcodes (e.g. `RTS`) and jumps (e.g.`JMP` and `BRA`) are unindented relative to the parent indentation.
  - Labels are indented at the parent level
  - Asar-only commands like `incsrc` and `print` are generally unindented
  - `bank` (for the label optimizer) is indented at the `PLB` level.
- Use `bank` (the function) to get the address bank, not `>>16`

## Licensing

The patch is, as far as permitted by copyright, licensed under the BSD1 license.
That means, the source code must be credited to the author, either his real name or pseudonym
"MarioFanGamer", but can be left unmentioned in the final product.
This primarily has organizational purposes: As a mod to a proprietary game, the license must not
be viral like GPL since the project modifies a proprietary game and most licenses require not
only attribution in the product but also the inclusion of the original license which is overkill
for the SMW hacking community and far too easy to violate (most only bother to include a
separate text file for credits).
For this reason, I included a license which only needs to be passed down at source code
distribution but not for when in use for the final product.

Auxillary demo files (found under `demo`) are copyrighted by the respective owners.

## Credits

Inline Layer 3 Messages (main code):
- MarioFanGamer

Demo:
- Levels: MarioFanGamer
- Messages: MarioFanGamer
- Layer 3 conversions of SMW graphics:
  - [Blue Mountains](https://www.smwcentral.net/?p=section&a=details&id=13031): S.R.H.
  - [Cave](https://www.smwcentral.net/?p=section&a=details&id=13197): Link13
  - [Clouds](https://www.smwcentral.net/?p=section&a=details&id=2544): allowiscous, imamelia
  - [Castle Pillars](https://www.smwcentral.net/?p=section&a=details&id=13029): S.R.H.
  - Original graphics: Nintendo
- PIXI: See [main repo](https://github.com/JackTheSpades/SpriteToolSuperDelux)
- Custom Info Box:
  - Original: Sonikku
  - Modifications to remove explosion, animations and VWF Dialogues support in favour of global messages: MarioFanGamer
- Remove Status Bar: lui
- Start+Select Advanced: MarioFanGamer
