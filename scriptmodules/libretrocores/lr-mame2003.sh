#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2003"
rp_module_desc="Arcade emu - MAME 0.78 port for libretro"
rp_module_menus="2+"

function depends_lr-mame2003() {
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_lr-mame2003() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2003-libretro.git
}

function build_lr-mame2003() {
    make clean
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        make ARCH="$CFLAGS -fsigned-char" CC="gcc-4.8" CXX="g++-4.8"
    else
        make ARCH="$CFLAGS -fsigned-char"
    fi
}

function install_lr-mame2003() {
    md_ret_files=(
        'mame2003_libretro.so'
        'README'
        'changed.txt'
        'whatsnew.txt'
        'whatsold.txt'
    )
}

function configure_lr-mame2003() {
    # remove old core library
    rm -f "$md_inst/mame078_libretro.so"

    mkRomDir "mame-libretro"
    ensureSystemretroconfig "mame-libretro"

    addSystem 1 "$md_id" "mame-libretro arcade mame" "$md_inst/mame2003_libretro.so"
}
