#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-desmume"
rp_module_desc="NDS emu - DESMUME"
rp_module_menus="4+"

function sources_lr-desmume() {
    gitPullOrClone "$md_build" https://github.com/libretro/desmume.git
}

function build_lr-desmume() {
    cd desmume
    make -f Makefile.libretro clean
    make -f Makefile.libretro platform=armvhardfloat
    md_ret_require="$md_build/desmume/desmume_libretro.so"
}

function install_lr-desmume() {
    md_ret_files=(
        'desmume/desmume_libretro.so'
    )
}

function configure_lr-desmume() {
    mkRomDir "nds"
    ensureSystemretroconfig "nds" 

    addSystem 0 "$md_id" "nds" "$md_inst/desmume_libretro.so"
}
