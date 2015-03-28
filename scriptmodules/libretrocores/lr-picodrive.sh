#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-picodrive"
rp_module_desc="Sega 8/16 bit emu - picodrive arm optimised libretro core"
rp_module_menus="2+"

function sources_lr-picodrive() {
    gitPullOrClone "$md_build" https://github.com/libretro/picodrive.git
    git submodule init
    git submodule update
}

function build_lr-picodrive() {
    make clean
    make -f Makefile.libretro platform=armv6
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
    ensureSystemretroconfig "megadrive" "phosphor.glslp"
    ensureSystemretroconfig "mastersystem" "phosphor.glslp"
    ensureSystemretroconfig "segacd"
    ensureSystemretroconfig "sega32x"

    addSystem 1 "$md_id" "mastersystem" "$md_inst/picodrive_libretro.so"
    addSystem 1 "$md_id" "megadrive" "$md_inst/picodrive_libretro.so"
    addSystem 1 "$md_id" "segacd" "$md_inst/picodrive_libretro.so"
    addSystem 1 "$md_id" "sega32x" "$md_inst/picodrive_libretro.so"
}
