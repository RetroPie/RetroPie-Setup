#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mednafen-ngp"
rp_module_desc="Neo Geo Pocket(Color)emu - Mednafen Neo Geo Pocket core port for libretro"
rp_module_menus="2+"

function sources_lr-mednafen-ngp() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-ngp-libretro.git
}

function build_lr-mednafen-ngp() {
    make clean
    make
    md_ret_require="$md_build/mednafen_ngp_libretro.so"
}

function install_lr-mednafen-ngp() {
    md_ret_files=(
        'mednafen_ngp_libretro.so'
    )
}

function configure_lr-mednafen-ngp() {
    mkRomDir "ngp"
    ensureSystemretroconfig "ngp"
    
    addSystem 1 "$md_id" "ngp" "$md_inst/mednafen_ngp_libretro.so"
}
