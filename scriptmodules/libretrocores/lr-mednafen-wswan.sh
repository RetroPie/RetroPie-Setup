#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-mednafen-ws"
rp_module_desc="Wonderswan emu - Mednafen WonderSwan core port for libretro"
rp_module_menus="4+"

function sources_lr-mednafen-ws() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-wswan-libretro.git
}

function build_lr-mednafen-ws() {
    make clean
    make
    md_ret_require="$md_build/mednafen_wswan_libretro.so"
}

function install_lr-mednafen-ws() {
    md_ret_files=(
        'README.md'
        'mednafen_wswan_libretro.so'
    )
}

function configure_lr-mednafen-ws() {

    mkRomDir "wonderswan"
    ensureSystemretroconfig "wonderswan"
    
    addSystem 1 "$md_id" "wonderswan" "$md_inst/mednafen_wswan_libretro.so"
}