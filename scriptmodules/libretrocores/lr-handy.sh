#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-handy"
rp_module_desc="Atari Lynx emulator - Handy port for libretro"
rp_module_menus="2+"

function sources_lr-handy() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-handy.git
}

function build_lr-handy() {
    make clean
    make
    md_ret_require="$md_build/handy_libretro.so"
}

function install_lr-handy() {
    md_ret_files=(
        'handy_libretro.so'
        'README.md'
    )
}

function configure_lr-handy() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/libretro-handy"

    mkRomDir "atarilynx"
    ensureSystemretroconfig "atarilynx"

    addSystem 1 "$md_id" "atarilynx" "$md_inst/handy_libretro.so"
}
