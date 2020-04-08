#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-stella"
rp_module_desc="Atari 2600 emulator - Stella (current) port for libretro"
rp_module_help="ROM Extensions: .a26 .bin .zip\n\nCopy your Atari 2600 roms to $romdir/atari2600"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/stella-libretro/master/stella/license.txt"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-stella() {
    gitPullOrClone "$md_build" https://github.com/stella-emu/stella.git
}

function build_lr-stella() {
    cd "src/libretro"
    make clean
    make -j`nproc`
    md_ret_require="$md_build/src/libretro/stella_libretro.so"
}

function install_lr-stella() {
    md_ret_files=(
        'src/libretro/stella_libretro.so'
        'License.txt'
    )
}

function configure_lr-stella() {
    mkRomDir "atari2600"
    ensureSystemretroconfig "atari2600"

    addEmulator 1 "$md_id" "atari2600" "$md_inst/stella_libretro.so"
    addSystem "atari2600"
}
