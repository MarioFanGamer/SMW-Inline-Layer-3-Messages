# Inline Layer 3 Messages for Super Mario World

This repository is a mod for the Super NES game Super Mario World.

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


## Contributing

### Code of conduct
- Be polite, don't insult others
- Any contribution for the main patch will be licensed under the BSD1 license (see [LICENSE] for more information)

### Syntax
- Labels are generally CamelCase, although underscores can be used for namespaces and sublabel access.
- RAM definitions:
  - Unless it's scratch RAM ($00-$0F range), always use labeled RAM addresses
  - Take advantage of Asar's label optimizer, only specify size explicitly for immediate addressing (and typically only when ambiguous).
  - When defining labels, make sure you mention the general usecase first (e.g. `Game`, `Player`) and then the specific use
  - Also label ROM addresses
  - Use defines for indirectly accessible memory like VRAM
- Comments:
  - Always comment functions, particularly what it takes as input
  - Also use comments for code blocks
  - Keep comments within codes at a minimum, it should be as self-explanatory as possible
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
for the SMW hacking community and easy to violate.
For this reason, I included a license which only needs to be passed down at source code
distribution but not for when in use for the final product.

Auxillary demo files (found under `demo`) are copyrighted by the respective owners.
