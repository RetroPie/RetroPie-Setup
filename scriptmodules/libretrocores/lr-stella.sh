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
rp_module_desc="Atari 2600 emulator - Stella core for libretro"
rp_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy your Atari 2600 roms to $romdir/atari2600"
rp_module_licence="GPL2 https://raw.githubusercontent.com/stella-emu/stella/master/License.txt"
rp_module_repo="git https://github.com/stella-emu/stella.git master :_get_commit_lr-stella"
rp_module_section="exp"

function _get_commit_lr-stella() {
    # GCC 11 is required after 2d57f9e0
    if [[ "$__gcc_version" -lt 11 ]]; then
        echo "2d57f9e0"
    fi
}

function sources_lr-stella() {
    gitPullOrClone
}

function build_lr-stella() {
    cd src/os/libretro
    make clean
    make LTO=""
    md_ret_require="$md_build/src/os/libretro/stella_libretro.so"
}

function install_lr-stella() {
    md_ret_files=(
        'README.md'
        'src/os/libretro/stella_libretro.so'
        'License.txt'
    )
}

function configure_lr-stella() {
    mkRomDir "atari2600"
    defaultRAConfig "atari2600"

    addEmulator 0 "$md_id" "atari2600" "$md_inst/stella_libretro.so"
    addSystem "atari2600"
}
