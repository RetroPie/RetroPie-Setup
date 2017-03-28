#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-imame4all"
rp_module_desc="Arcade emu - iMAME4all (based on MAME 0.37b5) port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your iMAME4all roms to either $romdir/mame-mame4all or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2000-libretro/master/readme.txt"
rp_module_section="main"

function sources_lr-imame4all() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2000-libretro.git
}

function build_lr-imame4all() {
    make clean
    local params=()
    isPlatform "arm" && params+=("ARM=1" "USE_CYCLONE=1")
    make "${params[@]}"
    md_ret_require="$md_build/mame2000_libretro.so"
}

function install_lr-imame4all() {
    md_ret_files=(
        'mame2000_libretro.so'
        'readme.md'
        'readme.txt'
        'whatsnew.txt'
    )
}

function configure_lr-imame4all() {
    local system
    for system in arcade mame-mame4all mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2000_libretro.so"
        addSystem "$system"
    done
}
