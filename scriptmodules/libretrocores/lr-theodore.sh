#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-theodore"
rp_module_desc="Thomson MO/TO 8-bit computers emulator for libretro"
rp_module_help="ROM Extension: .fd .sap .k7 .m7 .m5 .rom .zip\n\nCopy your Thomson TO roms to $romdir/thomson"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Zlika/theodore/master/LICENSE"
rp_module_section="exp"

function sources_lr-theodore() {
    gitPullOrClone "$md_build" https://github.com/Zlika/theodore.git
}

function build_lr-theodore() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/theodore_libretro.so"
}

function install_lr-theodore() {
    md_ret_files=(
        'theodore_libretro.so'
    )
}

function configure_lr-theodore() {
    mkRomDir "thomson"
    ensureSystemretroconfig "thomson"

    addEmulator 1 "$md_id" "thomson" "$md_inst/theodore_libretro.so"
    addSystem "thomson"
}
