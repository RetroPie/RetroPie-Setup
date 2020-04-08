#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-freej2me"
rp_module_desc="Java ME emulator - FreeJ2ME port for libretro."
rp_module_help="ROM Extensions: .jar .zip .7z\n\nCopy your Java ME (J2ME) roms to $romdir/j2me\n\nThe BIOS files freej2me-sdl.jar, freej2me.jar and freej2me-lr.jar will automatically installed in $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/hex007/freej2me/master/LICENSE"
rp_module_section="exp"
rp_module_flags="" 

function depends_lr-freej2me() {
    local depends=(openjdk-11-jre ant)
    getDepends "${depends[@]}"    
}

function sources_lr-freej2me() {
    gitPullOrClone "$md_build" https://github.com/hex007/freej2me.git
}

function build_lr-freej2me() {
    ant
    cd "src/libretro"
    make clean
    make -j`nproc`
    md_ret_require="$md_build/src/libretro/freej2me_libretro.so"
}

function install_lr-freej2me() {
    md_ret_files=(
	'build/freej2me.jar'
	'build/freej2me-lr.jar'
	'build/freej2me-sdl.jar'
	'src/libretro/retropie.txt'
	'src/libretro/freej2me_libretro.so'
    )
}

function configure_lr-freej2me() {
    mkRomDir "j2me"
    ensureSystemretroconfig "j2me"

    addEmulator 1 "$md_id" "j2me" "$md_inst/freej2me_libretro.so"
    addSystem "j2me"

    cp -Rv "$md_inst/freej2me-lr.jar" "$md_inst/freej2me-sdl.jar" "$md_inst/freej2me.jar" "$biosdir" 
    chown $user:$user -R "$biosdir/freej2me.jar" "$biosdir/freej2me-sdl.jar" "$biosdir/freej2me-lr.jar"
}
