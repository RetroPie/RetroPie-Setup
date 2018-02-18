#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="darkplaces-quake"
rp_module_desc="Quake 1 engine - Darkplaces Quake port with GLES rendering"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xonotic/darkplaces/master/COPYING"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function depends_darkplaces-quake() {
    local depends=(libsdl2-dev libjpeg-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_darkplaces-quake() {
    gitPullOrClone "$md_build" https://github.com/xonotic/darkplaces.git
    if isPlatform "rpi"; then
        applyPatch "$md_data/rpi.diff"
    fi
}

function build_darkplaces-quake() {
    make clean
    if isPlatform "rpi"; then
        make sdl-release DP_MAKE_TARGET=rpi
    else
        make sdl-release
    fi
}

function install_darkplaces-quake() {
    md_ret_files=(
        'darkplaces.txt'
        'darkplaces-sdl'
        'COPYING'
    )
}

function add_games_darkplaces-quake() {
    _add_games_lr-tyrquake "$md_inst/darkplaces-sdl -basedir $romdir/ports/quake -game %QUAKEDIR%"
}

function configure_darkplaces-quake() {
    mkRomDir "ports/quake"

    [[ "$md_mode" == "install" ]] && game_data_lr-tyrquake

    add_games_darkplaces-quake

    moveConfigDir "$home/.darkplaces" "$md_conf_root/quake/darkplaces"
}
