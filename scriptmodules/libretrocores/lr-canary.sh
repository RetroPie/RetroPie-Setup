#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-canary"
rp_module_desc="3DS emulator - Citra Canary for libretro"
rp_module_help="OpenGL >= 3.3 is required.\n\nROM Extensions: .3ds .3dsx .elf .axf .cci .cxi .app\n\nCopy your Nintendo 3DS roms to $romdir/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra/master/license.txt"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-canary() {
    getDepends cmake
}

function sources_lr-canary() {
    gitPullOrClone "$md_build" https://github.com/libretro/citra.git canary
}

function build_lr-canary() {
    mkdir build
    cd build
    cmake .. -DENABLE_LIBRETRO=1 -DLIBRETRO_STATIC=1 -DENABLE_SDL2=0 -DENABLE_QT=0 -DENABLE_WEB_SERVICE=0
    make -j`nproc`
    md_ret_require="$md_build/build/src/citra_libretro/citra_canary_libretro.so"
}

function install_lr-canary() {
    md_ret_files=(
        'build/src/citra_libretro/citra_canary_libretro.so'
    )
}

function configure_lr-canary() {
    mkRomDir "3ds"
    ensureSystemretroconfig "3ds"

    addEmulator 1 "$md_id" "3ds" "$md_inst/citra_canary_libretro.so"
    addSystem "3ds"
}
