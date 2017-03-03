#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdlpop"
rp_module_desc="SDLPoP - Port of Prince of Persia"
rp_module_licence="GPL3 https://raw.githubusercontent.com/NagyD/SDLPoP/master/doc/gpl-3.0.txt"
rp_module_section="opt"

function depends_sdlpop() {
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev
}

function sources_sdlpop() {
    gitPullOrClone "$md_build" https://github.com/NagyD/SDLPoP.git
    applyPatch "sdlpop.diff" <<\_EOF_
--- a/src/Makefile
+++ b/src/Makefile
@@ -14,7 +14,7 @@ LIBS := $(shell sdl2-config --libs) -lSDL2_image -lSDL2_mixer
 INCS := -I/opt/local/include
 CFLAGS += $(INCS) -Wall -std=gnu99 -D_GNU_SOURCE=1 -D_THREAD_SAFE -DOSX -O2
 else
-LIBS := $(shell pkg-config --libs   sdl2 SDL2_image SDL2_mixer)
+LIBS := $(shell pkg-config --libs   sdl2 SDL2_image SDL2_mixer) -lm
 INCS := $(shell pkg-config --cflags sdl2 SDL2_image SDL2_mixer)
 CFLAGS += $(INCS) -Wall -std=gnu99 -O2
 endif
_EOF_
}

function build_sdlpop() {
    cd src
    make
    md_ret_require="$md_build/prince"
}

function install_sdlpop() {
    md_ret_files=(
        'prince'
        'data'
        'doc'
    )
    cp -v "SDLPoP.ini" "$md_inst/SDLPoP.ini.def"
    sed -i "s/use_correct_aspect_ratio = false/use_correct_aspect_ratio = true/" "$md_inst/SDLPoP.ini.def"
}

function configure_sdlpop() {
    addPort "$md_id" "sdlpop" "Prince of Persia" "pushd $md_inst; $md_inst/prince full; popd"

    copyDefaultConfig "$md_inst/SDLPoP.ini.def" "$md_conf_root/$md_id/SDLPoP.ini"
    moveConfigFile "$md_inst/SDLPoP.ini" "$md_conf_root/$md_id/SDLPoP.ini"

    moveConfigFile "$md_inst/PRINCE.SAV" "$md_conf_root/$md_id/PRINCE.SAV"

    chown -R $user:$user "$md_conf_root/$md_id"
}
