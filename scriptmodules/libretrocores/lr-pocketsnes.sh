#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-pocketsnes"
rp_module_desc="SNES emu - ARM based SNES emulator for libretro"
rp_module_menus="2+"

function sources_lr-pocketsnes() {
    gitPullOrClone "$md_build" git://github.com/libretro/pocketsnes-libretro.git
}

function build_lr-pocketsnes() {
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_lr-pocketsnes() {
    md_ret_files=(
        'libretro.so'
        'README.txt'
    )
}

function configure_lr-pocketsnes() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/pocketsnes"

    mkRomDir "snes"
    ensureSystemretroconfig "snes" "snes_phosphor.glslp"

    local def=0
    isPlatform "rpi1" && def=1
    addSystem $def "$md_id" "snes" "$md_inst/libretro.so"
}
