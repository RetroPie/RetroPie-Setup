#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-4do"
rp_module_desc="3DO emu - 4DO/libfreedo port for libretro"
rp_module_menus="4+"

function sources_lr-4do() {
    gitPullOrClone "$md_build" https://github.com/libretro/4do-libretro.git
}

function build_lr-4do() {
    make clean
    make
    md_ret_require="$md_build/4do_libretro.so"
}

function install_lr-4do() {
    md_ret_files=(
        '4do_libretro.so'
    )
}

function configure_lr-4do() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/4do"

    mkRomDir "3do"
    ensureSystemretroconfig "3do"

    addSystem 1 "$md_id" "3do" "$md_inst/4do_libretro.so"

    __INFMSGS+=("For the 3DO emulator you need to copy panazf10.bin to the folder $biosdir.")
}
