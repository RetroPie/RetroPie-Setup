#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-race"
rp_module_desc="Neo Geo Pocket (Color) emulator - RACE! port for libretro."
rp_module_help="ROM Extensions: .ngp .ngc .ngpc .npc .zip .7z\n\nCopy your Neo Geo Pocket roms to $romdir/ngp\nCopy your Neo Geo Pocket Color roms to $romdir/ngpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/RACE/master/license.txt"
rp_module_section="opt"
rp_module_flags="" 

function sources_lr-race() {
    gitPullOrClone "$md_build" https://github.com/libretro/RACE.git
}

function build_lr-race() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/race_libretro.so"
}

function install_lr-race() {
    md_ret_files=(
	'license.txt'
	'race_libretro.so'
    )
}

function configure_lr-race() {
    local system
    for system in ngp ngpc; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 1 "$md_id" "$system" "$md_inst/race_libretro.so"
        addSystem "$system"
    done
}
