#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mednafen-wswan"
rp_module_desc="Wonderswan emu - Mednafen WonderSwan core port for libretro"
rp_module_menus="2+"

function sources_lr-mednafen-wswan() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-wswan-libretro.git
}

function build_lr-mednafen-wswan() {
    make clean
    make
    md_ret_require="$md_build/mednafen_wswan_libretro.so"
}

function install_lr-mednafen-wswan() {
    md_ret_files=(
        'mednafen_wswan_libretro.so'
    )
}

function configure_lr-mednafen-wswan() {
    mkRomDir "wonderswan"
    ensureSystemretroconfig "wonderswan"

    addSystem 1 "$md_id" "wonderswan" "$md_inst/mednafen_wswan_libretro.so"
}
