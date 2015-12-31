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
rp_module_menus="4+"
rp_module_flags="dispmanx"

function depends_zdoom() {
    getDepends libev-dev libsdl2-dev libmpg123-dev libsndfile1-dev zlib1g-dev libbz2-dev timidity cmake
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
    if [[ "$__raspbian_ver" -lt "8" ]]; then
        getDepends libjpeg8-dev
    else
        getDepends libjpeg-dev
    fi
}

function sources_zdoom() {
    gitPullOrClone "$md_build" https://github.com/rheit/zdoom.git
}

function build_zdoom() {
    rm -rf release
    mkdir -p release
    cd release
    cmake -DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release -DNO_ASM=1 -DCMAKE_CXX_COMPILER=g++-4.8 -DCMAKE_C_COMPILER=gcc-4.8 ..
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
    mkRomDir "ports"
    mkRomDir "ports/doom"

    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/zdoom" "$configdir/doom"

    # download doom 1 shareware
    if [[ ! -f "$romdir/ports/doom/doom1.wad" ]]; then
        wget "$__archive_url/doom1.wad" -O "$romdir/ports/doom/doom1.wad"
    fi
    chown $user:$user "$romdir/ports/doom/doom1.wad"

    addPort "$md_id" "doom" "Doom" "$md_inst/zdoom -iwad $romdir/ports/doom/doom1.wad"
}
