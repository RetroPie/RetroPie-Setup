#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="zdoom"
rp_module_desc="ZDoom - Enhanced port of the official DOOM source"
rp_module_licence="OTHER https://raw.githubusercontent.com/RetroPie/zdoom/master/docs/licenses/README.TXT"
rp_module_section="opt"
rp_module_flags=""

function depends_zdoom() {
    local depends=(
        libev-dev libsdl2-dev libmpg123-dev libsndfile1-dev zlib1g-dev libbz2-dev
        timidity freepats cmake libopenal-dev libjpeg-dev
    )

    getDepends "${depends[@]}"
}

function sources_zdoom() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/zdoom.git retropie
}

function build_zdoom() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/release/zdoom"
}

function install_zdoom() {
    md_ret_files=(
        'release/zdoom'
        'release/zdoom.pk3'
    )
}

function add_games_zdoom() {
    _add_games_lr-prboom "DOOMWADDIR=$romdir/ports/doom $md_inst/zdoom +set fullscreen 1 -iwad %ROM%"
}

function configure_zdoom() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.config/zdoom" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_zdoom
}
