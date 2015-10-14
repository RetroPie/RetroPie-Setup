#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mgba"
rp_module_desc="GBA emulator - MGBA (optimised) port for libretro"
rp_module_menus="2+"
rp_module_flags="!rpi1"

function sources_lr-mgba() {
    gitPullOrClone "$md_build" https://github.com/libretro/mgba.git
}

function build_lr-mgba() {
    make -f Makefile.libretro clean
    if isPlatform "rpi1"; then
        make -f Makefile.libretro
    else
        make -f Makefile.libretro HAVE_NEON=1
    fi
    md_ret_require="$md_build/mgba_libretro.so"
}

function install_lr-mgba() {
    md_ret_files=(
        'mgba_libretro.so'
        'CHANGES'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-mgba() {
    mkRomDir "gba"
    ensureSystemretroconfig "gba"

    addSystem 0 "$md_id" "gba" "$md_inst/mgba_libretro.so"
}
