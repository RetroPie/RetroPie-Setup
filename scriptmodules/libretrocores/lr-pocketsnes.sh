#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-pocketsnes"
rp_module_desc="SNES emu - ARM based SNES emulator for libretro"
rp_module_menus="2+"

function sources_lr-pocketsnes() {
    gitPullOrClone "$md_build" https://github.com/libretro/pocketsnes-libretro.git
}

function build_lr-pocketsnes() {
    make clean
    CFLAGS="$CFLAGS -Wa,-mimplicit-it=thumb" make ARM_ASM=1
    md_ret_require="$md_build/pocketsnes_libretro.so"
}

function install_lr-pocketsnes() {
    md_ret_files=(
        'pocketsnes_libretro.so'
        'README.txt'
    )
}

function configure_lr-pocketsnes() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/pocketsnes"
    # remove old core library
    rm -f "$md_inst/libretro.so"

    mkRomDir "snes"
    ensureSystemretroconfig "snes" "snes_phosphor.glslp"

    local def=0
    isPlatform "rpi1" && def=1
    addSystem $def "$md_id" "snes" "$md_inst/pocketsnes_libretro.so"
}
