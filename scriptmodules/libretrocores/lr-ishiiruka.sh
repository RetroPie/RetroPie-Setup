#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-ishiiruka"
rp_module_desc="Gamecube/Wii emulator - Ishiiruka port for libretro"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .nkit\n\nCopy your gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/ishiiruka/master/license.txt"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-ishiiruka() {
    depends_dolphin
}

function sources_lr-ishiiruka() {
    gitPullOrClone "$md_build" https://github.com/libretro/Ishiiruka.git
}

function build_lr-ishiiruka() {
    mkdir build
    cd build
    cmake .. -DLIBRETRO=ON
    make clean
    make j`nproc`
    md_ret_require="$md_build/build/Binaries/ishiiruka_libretro.so"
}

function install_lr-ishiiruka() {
    md_ret_files=(
	'build/Binaries/ishiiruka_libretro.so'
    )
}

function configure_lr-ishiiruka() {
    local system
    for system in gc wii; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 1 "$md_id" "$system" "$md_inst/ishiiruka_libretro.so"
        addSystem "$system"
    done
}
