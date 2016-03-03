#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame"
rp_module_desc="MAME emulator - MAME (current) port for libretro"
rp_module_menus="4+"

function sources_lr-mame() {
    gitPullOrClone "$md_build" https://github.com/libretro/MAME.git
}

function build_lr-mame() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro SUBTARGET=arcade
    md_ret_require="$md_build/mamearcade_libretro.so"
}

function install_lr-mame() {
    md_ret_files=(
        'mamearcade_libretro.so'
    )
}

function configure_lr-mame() {
    mkRomDir "arcade"
    mkRomDir "mame-libretro"
    ensureSystemretroconfig "arcade"
    ensureSystemretroconfig "mame-libretro"

    addSystem 0 "$md_id" "arcade" "$md_inst/mamearcade_libretro.so"
    addSystem 0 "$md_id" "mame-libretro arcade mame" "$md_inst/mamearcade_libretro.so"
}
