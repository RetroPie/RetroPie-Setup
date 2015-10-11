#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-armsnes"
rp_module_desc="SNES emu - forked from pocketsnes focused on performance"
rp_module_menus="2+"

function sources_lr-armsnes() {
    gitPullOrClone "$md_build" https://github.com/rmaz/ARMSNES-libretro
    patch -p1 <<\_EOF_
diff --git a/src/ppu.cpp b/src/ppu.cpp
index 19340fb..6d1af27 100644
--- a/src/ppu.cpp
+++ b/src/ppu.cpp
@@ -714,7 +714,7 @@ uint8 S9xGetCPU(uint16 Address)
 						}
 					}
 					return (
-						(IPPU.Joypads[0]
+						(IPPU.Joypads[1]
 							>> (PPU.Joypad2ButtonReadPos++ ^ 15))
 							& 1);
 				}
_EOF_
}

function build_lr-armsnes() {
    make clean
    CFLAGS="$CFLAGS -Wa,-mimplicit-it=thumb" make
    md_ret_require="$md_build/libpocketsnes.so"
}

function install_lr-armsnes() {
    md_ret_files=(
        'libpocketsnes.so'
    )
}

function configure_lr-armsnes() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/armsnes"

    mkRomDir "snes"
    ensureSystemretroconfig "snes" "snes_phosphor.glslp"

    addSystem 0 "$md_id" "snes" "$md_inst/libpocketsnes.so"
}
