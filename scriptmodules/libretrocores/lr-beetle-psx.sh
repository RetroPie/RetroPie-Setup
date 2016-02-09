#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-psx"
rp_module_desc="PlayStation emulator - Mednafen PSX Port for libretro"
rp_module_menus="4+"
rp_module_flags="!arm"

function sources_lr-beetle-psx() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-psx-libretro.git
}

function build_lr-beetle-psx() {
    make clean
    make
    md_ret_require="$md_build/mednafen_psx_libretro.so"
}

function install_lr-beetle-psx() {
    md_ret_files=(
        'mednafen_psx_libretro.so'
    )
}

function configure_lr-beetle-psx() {
    mkRomDir "psx"
    ensureSystemretroconfig "psx"

    addSystem 0 "$md_id" "psx" "$md_inst/mednafen_psx_libretro.so"
}
