#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dice"
rp_module_desc="Discrete Integrated Circuit Emulator for machines without a CPU - DICE core for libretro"
rp_module_help="ROM Extensions: .zip .dmy\n\nCopy your DICE TTL roms to either $romdir/arcade or $romdir/dice"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mittonk/dice-libretro/main/LICENSE.txt"
rp_module_repo="git https://github.com/mittonk/dice-libretro.git main"
rp_module_section="opt"

function depends_lr-dice() {
    getDepends zlib1g-dev
}

function sources_lr-dice() {
    gitPullOrClone
}

function build_lr-dice() {
    make clean
    make
    md_ret_require="$md_build/dice_libretro.so"
}

function install_lr-dice() {
    md_ret_files=(
        'README.md'
        'dice_libretro.so'
        'LICENSE.txt'
    )
}

function configure_lr-dice() {
    local system
    for system in arcade dice; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/dice_libretro.so"
        addSystem "$system"
    done
}
