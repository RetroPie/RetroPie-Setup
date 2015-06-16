#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-caprice32"
rp_module_desc="Amstrad CPC emu - Caprice32 port for libretro"
rp_module_menus="4+"

function sources_lr-caprice32() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-cap32.git
}

function build_lr-caprice32() {
    make clean
    make
    md_ret_require="$md_build/cap32_libretro.so"
}

function install_lr-caprice32() {
    md_ret_files=(
        'cap32_libretro.so'
    )
}

function configure_lr-caprice32() {
    mkRomDir "amstradcpc"
    ensureSystemretroconfig "amstradcpc"

    addSystem 0 "$md_id" "amstradcpc" "$md_inst/cap32_libretro.so"
}
