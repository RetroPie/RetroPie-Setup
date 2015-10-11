#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-o2em"
rp_module_desc="Odyssey 2 / Videopac emu - O2EM port for libretro"
rp_module_menus="2+"

function sources_lr-o2em() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-o2em
}

function build_lr-o2em() {
    make clean
    make
    md_ret_require="$md_build/o2em_libretro.so"
}

function install_lr-o2em() {
    md_ret_files=(
        'o2em_libretro.so'
        'README.md'
    )
}

function configure_lr-o2em() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/o2em"

    mkRomDir "videopac"
    ensureSystemretroconfig "videopac"

    addSystem 1 "$md_id" "videopac" "$md_inst/o2em_libretro.so"

    __INFMSGS+=("For the Odyssey 2 / Videopac emulator you need to copy o2rom.bin to the folder $biosdir.")
}
