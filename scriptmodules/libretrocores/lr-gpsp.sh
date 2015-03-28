#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-gpsp"
rp_module_desc="GBA emu - gpSP port for libretro"
rp_module_menus="2+"

function sources_lr-gpsp() {
    gitPullOrClone "$md_build" https://github.com/libretro/gpsp.git
}

function build_lr-gpsp() {
    make clean
    rpSwap on 512
    make platform=armv
    rpSwap off
    md_ret_require="$md_build/gpsp_libretro.so"
}

function install_lr-gpsp() {
    md_ret_files=(
        'gpsp_libretro.so'
        'COPYING'
        'readme.txt'
        'game_config.txt'
    )
}

function configure_lr-gpsp() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/gpsp-libretro"

    mkRomDir "gba"
    ensureSystemretroconfig "gba"

    delSystem "$md_id" "gba-gpsp-libretro"
    addSystem 1 "$md_id" "gba" "$md_inst/gpsp_libretro.so"
}
