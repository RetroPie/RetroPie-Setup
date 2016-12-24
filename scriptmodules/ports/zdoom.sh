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
rp_module_section="opt"
rp_module_flags="dispmanx !mali"

function depends_zdoom() {
    local depends=(
        libev-dev libsdl2-dev libmpg123-dev libsndfile1-dev zlib1g-dev libbz2-dev
        timidity freepats cmake libopenal-dev libjpeg-dev
    )

    getDepends "${depends[@]}"
}

function sources_zdoom() {
    gitPullOrClone "$md_build" https://github.com/rheit/zdoom.git
}

function build_zdoom() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    # workaround for armv7+ on Raspbian armv6 userland due to GCC ABI incompatibility
    # same issue as https://github.com/hrydgard/ppsspp/pull/8117
    if [[ "$__os_id" == "Raspbian" ]]; then
        CXXFLAGS+=" -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2" cmake "${params[@]}" ..
    else
        cmake "${params[@]}" ..
    fi
    make
    md_ret_require="$md_build/release/zdoom"
}

function install_zdoom() {
    md_ret_files=(
        'release/zdoom'
        'release/zdoom.pk3'
    )
}

function configure_zdoom() {
    addPort "$md_id" "doom" "Doom" "$md_inst/zdoom -iwad $romdir/ports/doom/doom1.wad"

    mkRomDir "ports/doom"

    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/zdoom" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom
}
