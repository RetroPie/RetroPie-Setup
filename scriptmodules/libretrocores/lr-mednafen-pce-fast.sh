#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
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

    addSystem 0 "$md_id" "pcengine" "$md_inst/mednafen_pce_fast_libretro.so"
}
