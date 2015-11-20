#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mednafen-pce-fast"
rp_module_desc="PCEngine emu - Mednafen PCE Fast port for libretro"
rp_module_menus="2+"

function sources_lr-mednafen-pce-fast() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-pce-fast-libretro.git
}

function build_lr-mednafen-pce-fast() {
    make clean
    make
    md_ret_require="$md_build/mednafen_pce_fast_libretro.so"
}

function install_lr-mednafen-pce-fast() {
    md_ret_files=(
        'mednafen_pce_fast_libretro.so'
        'README.md'
    )
}

function configure_lr-mednafen-pce-fast() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/mednafenpcefast"

    mkRomDir "pcengine"
    ensureSystemretroconfig "pcengine"

    addSystem 1 "$md_id" "pcengine" "$md_inst/mednafen_pce_fast_libretro.so"
}
