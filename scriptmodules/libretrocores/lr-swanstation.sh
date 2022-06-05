#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-swanstation"
rp_module_desc="Playstation emulator - Duckstation fork for libretro"
rp_module_help="ROM Extensions: .exe .img .cue .bin .chd .psf .m3u .pbp\n\nCopy your PSX roms to $romdir/psx\n\nCopy the required BIOS file SCPH1001.BIN to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/swanstation/main/LICENSE"
rp_module_repo="git https://github.com/libretro/swanstation.git main"
rp_module_section="exp"
rp_module_flags=" "

function sources_lr-swanstation() {
    gitPullOrClone
}


function depends_lr-swanstation() {
        local depends=(cmake libsdl2-dev libsnappy-dev pkg-config libevdev-dev libgbm-dev libdrm-dev)
    getDepends "${depends[@]}"
}

function build_lr-swanstation() {
local params=(-DCMAKE_BUILD_TYPE=Release)
    if isPlatform "x11"; then
        params+=(-DUSE_X11=ON)
    else
        params+=(-DUSE_X11=OFF)
    fi
    if isPlatform "kms"; then
        params+=(-DUSE_DRMKMS=ON)
    else
        params+=(-DUSE_DRMKMS=OFF)
    fi
    cmake "${params[@]}" .
    make clean
    make  
    md_ret_require="$md_build/swanstation_libretro.so"
}

function install_lr-swanstation() {
    md_ret_files=(
        'swanstation_libretro.so'
        'README.md'
    )
}

function configure_lr-swanstation() {
    mkRomDir "psx"
    defaultRAConfig "psx"

    addEmulator 1 "$md_id" "psx" "$md_inst/swanstation_libretro.so"

    addSystem "psx"

}
