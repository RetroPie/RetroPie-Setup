#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2014"
rp_module_desc="Arcade emu - MAME 0.159 port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2014-libretro/master/docs/license.txt"
rp_module_section="exp"

function sources_lr-mame2014() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2014-libretro.git
}

function build_lr-mame2014() {
    rpSwap on 1200
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/mame2014_libretro.so"
}

function install_lr-mame2014() {
    md_ret_files=(
        'mame2014_libretro.so'
        'docs/README-original.md'
    )
}

function configure_lr-mame2014() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2014_libretro.so"
        addSystem "$system"
    done
}
