#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="tyrquake"
rp_module_desc="Quake 1 engine - TyrQuake port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/tyrquake/master/gnu.txt"
rp_module_section="opt"

function depends_tyrquake() {
    getDepends libsdl2-dev
}

function sources_tyrquake() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/tyrquake.git
}

function build_tyrquake() {
    local params=(USE_SDL=Y USE_XF86DGA=N)
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/bin/tyr-quake"
}

function install_tyrquake() {
    md_ret_files=(
        'changelog.txt'
        'readme.txt'
        'readme-id.txt'
        'gnu.txt'
        'bin'
    )
}

function add_games_tyrquake() {
    _add_games_lr-tyrquake "$md_inst/bin/tyr-quake -basedir $romdir/ports/quake -game %QUAKEDIR%"
    if isPlatform "x11"; then
        addEmulator 1 "$md_id-gl" "quake ports" "$md_inst/bin/tyr-glquake -basedir $romdir/ports/quake -game %QUAKEDIR%"
    fi
}

function configure_tyrquake() {
    mkRomDir "ports/quake"

    [[ "$md_mode" == "install" ]] && game_data_lr-tyrquake

    add_games_tyrquake

    moveConfigDir "$home/.tyrquake" "$md_conf_root/quake/tyrquake"
}
