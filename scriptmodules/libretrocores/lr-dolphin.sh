#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dolphin"
rp_module_desc="Gamecube/Wii emulator - Dolphin port for libretro"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz\n\nCopy your gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dolphin/master/license.txt"
rp_module_section="exp"
rp_module_flags="!arm !aarch64"

function depends_lr-dolphin() {
    depends_dolphin
}

function sources_lr-dolphin() {
    gitPullOrClone "$md_build" https://github.com/libretro/dolphin
}

function build_lr-dolphin() {
    mkdir build
    cd build
    cmake .. -DLIBRETRO=ON -DLIBRETRO_STATIC=1
    make clean
    make
    md_ret_require="$md_build/build/dolphin_libretro.so"
}

function install_lr-dolphin() {
    md_ret_files=(
        'build/dolphin_libretro.so'
    )
}

function configure_lr-dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    ensureSystemretroconfig "gc"
    ensureSystemretroconfig "wii"

    addEmulator 1 "$md_id" "gc" "$md_inst/dolphin_libretro.so"
    addEmulator 1 "$md_id" "wii" "$md_inst/dolphin_libretro.so"

    addSystem "gc"
    addSystem "wii"
}
