#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-picodrive"
rp_module_desc="Sega 8/16 bit emu - picodrive arm optimised libretro core"
rp_module_menus="2+"
rp_module_flags=""

function sources_lr-picodrive() {
    gitPullOrClone "$md_build" https://github.com/libretro/picodrive.git
    git submodule init
    git submodule update
}

function build_lr-picodrive() {
    make clean
    if isPlatform "arm"; then
        make -f Makefile.libretro platform=raspberrypi
    else
        make -f Makefile.libretro
    fi
    md_ret_require="$md_build/picodrive_libretro.so"
}

function install_lr-picodrive() {
    md_ret_files=(
        'AUTHORS'
        'COPYING'
        'picodrive_libretro.so'
        'README'
    )
}

function configure_lr-picodrive() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/picodrive"

    mkRomDir "megadrive"
    mkRomDir "mastersystem"
    mkRomDir "segacd"
    mkRomDir "sega32x"
    ensureSystemretroconfig "megadrive"
    ensureSystemretroconfig "mastersystem"
    ensureSystemretroconfig "segacd"
    ensureSystemretroconfig "sega32x"

    addSystem 1 "$md_id" "mastersystem" "$md_inst/picodrive_libretro.so"
    addSystem 1 "$md_id" "megadrive" "$md_inst/picodrive_libretro.so"
    addSystem 1 "$md_id" "segacd" "$md_inst/picodrive_libretro.so"
    addSystem 1 "$md_id" "sega32x" "$md_inst/picodrive_libretro.so"
}
