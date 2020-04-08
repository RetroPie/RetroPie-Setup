#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-yabasanshiro"
rp_module_desc="Sega Saturn emulator - Yaba Sanshiro port for libretro"
rp_module_help="OpenGL Core >= 3.3 | OpenGL ES >= 3.0 is required.\n\nROM Extensions: .iso .cue .zip .ccd .mds .chd\n\nCopy your Sega Saturn roms to $romdir/saturn\n\nCopy the required BIOS file saturn_bios.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/yabasanshiro/yabause/COPYING"
rp_module_section="exp"
rp_module_flags="!all armv7 neon 64bit"

function sources_lr-yabasanshiro() {
    gitPullOrClone "$md_build" https://github.com/libretro/yabause.git yabasanshiro
}

function build_lr-yabasanshiro() {
    cd yabause/src/libretro
    make clean
    make
    md_ret_require="$md_build/yabause/src/libretro/yabasanshiro_libretro.so"
}

function install_lr-yabasanshiro() {
    md_ret_files=(
        'yabause/src/libretro/yabasanshiro_libretro.so'
        'yabause/AUTHORS'
        'yabause/COPYING'
        'yabause/ChangeLog'
        'yabause/GOALS'
        'yabause/README'
        'yabause/README.LIN'
    )
}

function configure_lr-yabasanshiro() {
    mkRomDir "saturn"
    ensureSystemretroconfig "saturn"

    addEmulator 1 "$md_id" "saturn" "$md_inst/yabasanshiro_libretro.so"
    addSystem "saturn"
}
