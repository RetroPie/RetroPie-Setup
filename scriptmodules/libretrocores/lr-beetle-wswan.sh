#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-wswan"
rp_module_desc="Wonderswan emu - Mednafen WonderSwan core port for libretro"
rp_module_help="ROM Extensions: .ws .wsc .zip\n\nCopy your Wonderswan roms to $romdir/wonderswan\n\nCopy your Wonderswan Color roms to $romdir/wonderswancolor"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-wswan-libretro/master/COPYING"
rp_module_section="opt"

function _update_hook_lr-beetle-wswan() {
    # move from old location and update emulators.cfg
    renameModule "lr-mednafen-wswan" "lr-beetle-wswan"
}

function sources_lr-beetle-wswan() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-wswan-libretro.git
}

function build_lr-beetle-wswan() {
    make clean
    make
    md_ret_require="$md_build/mednafen_wswan_libretro.so"
}

function install_lr-beetle-wswan() {
    md_ret_files=(
        'mednafen_wswan_libretro.so'
    )
}

function configure_lr-beetle-wswan() {
    mkRomDir "wonderswan"
    mkRomDir "wonderswancolor"
    ensureSystemretroconfig "wonderswan"
    ensureSystemretroconfig "wonderswancolor"

    addEmulator 1 "$md_id" "wonderswan" "$md_inst/mednafen_wswan_libretro.so"
    addEmulator 1 "$md_id" "wonderswancolor" "$md_inst/mednafen_wswan_libretro.so"
    addSystem "wonderswan"
    addSystem "wonderswancolor"
}
