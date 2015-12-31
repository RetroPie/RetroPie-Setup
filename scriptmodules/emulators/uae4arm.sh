#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uae4arm"
rp_module_desc="Amiga emulator with JIT support"
rp_module_menus="2+"
rp_module_flags="!x86"

function depends_uae4arm() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev libsdl-ttf2.0-dev libguichan-dev
}

function sources_uae4arm() {
    gitPullOrClone "$md_build" https://github.com/Chips-fr/uae4arm-rpi/
}

function build_uae4arm() {
    if isPlatform "rpi"; then
        make PLATFORM=rpi1 CPU_FLAGS=""
    else
        make PLATFORM=rpi2 CPU_FLAGS="-mfpu=neon"
    fi
    md_ret_require="$md_build/uae4arm"
}

function install_uae4arm() {
    md_ret_files=(
        'conf'
        'data'
        'kickstarts'
        'uae4arm'
        'savestates'
        'screenshots'
    )
}

function configure_uae4arm() {
    mkRomDir "amiga"

    mkUserDir "$md_inst/conf"
    
    # symlinks to optional kickstart roms in our BIOS dir
    for rom in kick12.rom kick13.rom kick20.rom kick31.rom; do
        ln -sf "$biosdir/$rom" "$md_inst/kickstarts/$rom"
    done

    cat > "$romdir/amiga/+Start UAE4Arm.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./uae4arm
popd
_EOF_
    chmod a+x "$romdir/amiga/+Start UAE4Arm.sh"
    chown $user:$user "$romdir/amiga/+Start UAE4Arm.sh"

    addSystem 1 "$md_id" "amiga" "$romdir/amiga/+Start\ UAE4Arm.sh" "Amiga" ".sh"
}
