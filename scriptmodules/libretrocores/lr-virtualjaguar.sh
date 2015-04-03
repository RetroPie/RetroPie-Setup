#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-virtualjaguar"
rp_module_desc="Atari Jaguar emu - Virtual Jaguar (optimised) port for libretro"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_lr-virtualjaguar() {
    gitPullOrClone "$md_build" https://github.com/libretro/virtualjaguar-libretro.git
}

function build_lr-virtualjaguar() {
    make clean
    make
    md_ret_require="$md_build/virtualjaguar_libretro.so"
}

function install_lr-virtualjaguar() {
    md_ret_files=(
        'virtualjaguar_libretro.so'
        'README.md'
    )
}

function configure_lr-virtualjaguar() {
    mkRomDir "atarijaguar"
    ensureSystemretroconfig "atarijaguar"
    
    addSystem 1 "$md_id" "atarijaguar" "$md_inst/virtualjaguar_libretro.so"
}
