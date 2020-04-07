#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-cannonball"
rp_module_desc="An Enhanced OutRun engine for libretro"
rp_module_help="ROM Extensions: .game .88\n\nYou need to unzip your OutRun set B from latest MAME (outrun.zip) to $romdir/ports/cannonball. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/cannonball/master/docs/license.txt"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-cannonball() {
    depends_cannonball
}

function sources_lr-cannonball() {
    gitPullOrClone "$md_build" https://github.com/libretro/cannonball.git
}

function build_lr-cannonball() {
    > CannonBall.game
    make clean
    make -j`nproc`
    md_ret_require="$md_build/cannonball_libretro.so"
}

function install_lr-cannonball() {
    md_ret_files=(
	'CannonBall.game'
	'cannonball_libretro.so'
    )
}

function game_data_lr-cannonball() {
    downloadAndExtract "http://buildbot.libretro.com/assets/cores/Cannonball/CannonBall.zip" "$romdir/ports/"
    cp -Rv "$md_inst/CannonBall.game" "$romdir/ports/cannonball"
    chown -R $user:$user "$romdir/ports/cannonball"
}

function configure_lr-cannonball() {
    local script
    setConfigRoot "ports"

    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "$md_inst/cannonball_libretro.so" "$romdir/ports/cannonball/CannonBall.game"

    if [[ ! -f "$romdir/ports/cannonball" ]]; then
        game_data_lr-cannonball
    fi

    ensureSystemretroconfig "ports/cannonball"
}
