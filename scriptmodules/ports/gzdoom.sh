#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gzdoom"
rp_module_desc="gzdoom - Enhanced port of the official DOOM source"
rp_module_licence="GPL3 https://raw.githubusercontent.com/coelckers/gzdoom/master/docs/licenses/README.TXT"
rp_module_section="exp"
rp_module_flags=""

function depends_gzdoom() {
    local depends=(libgme-dev libsdl2-dev libsndfile1-dev)

    depends_zdoom "${depends[@]}"
}

function sources_gzdoom() {
    gitPullOrClone "$md_build" https://github.com/coelckers/gzdoom
}

function build_gzdoom() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    if isPlatform "armv8"; then
        params+=(-DUSE_ARMV8=On)
    fi
    cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/release/gzdoom"
}

function install_gzdoom() {
    md_ret_files=(
        'release/brightmaps.pk3'
        'release/gzdoom'
        'release/gzdoom.pk3'
        'release/lights.pk3'
        'release/zd_extra.pk3'
        'README.md'
    )
}

function add_games_gzdoom() {
    local params=("+set fullscreen 1")
    if isPlatform "gles"; then
        params+=("+set vid_renderer 0")
    fi
    _add_games_lr-prboom "$md_inst/gzdoom.sh %ROM% ${params[@]}"
}

function configure_gzdoom() {
    configure_zdoom
}
