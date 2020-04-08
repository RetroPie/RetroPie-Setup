#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-gearboy"
rp_module_desc="Game Boy (Color) emulator - Gearboy port for libretro."
rp_module_help="ROM Extensions: .gb .gbc .dmg .cgb .sgb .zip .7z\n\nCopy your GameBoy roms to $romdir/gb\nCopy your GameBoy Color roms to $romdir/gbc"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/Gearboy/master/LICENSE"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-gearboy() {
    gitPullOrClone "$md_build" https://github.com/drhelius/Gearboy.git
}

function build_lr-gearboy() {
    cd "platforms/libretro"
    make clean
    make -j`nproc`
    md_ret_require="$md_build/platforms/libretro/gearboy_libretro.so"
}

function install_lr-gearboy() {
    md_ret_files=(
        'platforms/libretro/gearboy_libretro.so'
    )
}

function configure_lr-gearboy() {
    for x in gb gbc; do
        mkRomDir "$x"
        ensureSystemretroconfig "$x"

        addEmulator 1 "$md_id" "$x" "$md_inst/gearboy_libretro.so"
        addSystem "$x"
    done
}
