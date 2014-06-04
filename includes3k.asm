#define M3K

#include "vic.defs.asm"
#include "game.defs.asm"
#include "zeropage.asm"

#include "basic-loader.asm"

#include "init.asm"
#include "intro.asm"

#include "main.asm"
#include "sprites.asm"
#include "controllers.asm"

#include "stackmem-start.asm"
#include "random.asm"
#include "score.asm"
#include "stackmem-end.asm"

#include "lowmem-start.asm"
#include "blitter.asm"
#include "chars.asm"
#include "screen.asm"
#include "math.asm"
#include "level-stars.asm"
#include "level-scout.asm"
#include "tiles.asm"
#include "bits.asm"
#include "level-data.asm"
#include "lowmem-end.asm"

#include "init-end.asm"

#include "gfx-sprites.asm"
#include "gfx-tiles.asm"
#include "level.asm"
#include "level-bullet.asm"
#include "level-sniper.asm"
#include "foreground.asm"

realend:
