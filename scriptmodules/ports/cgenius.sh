#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cgenius"
rp_module_desc="Commander Genius - Modern Interpreter for the Commander Keen Games (Vorticon and Galaxy Games)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gerstrong/Commander-Genius/master/COPYRIGHT"
rp_module_section="exp"

function depends_cgenius() {
    getDepends build-essential cmake libcurl4-openssl-dev libvorbis-dev libogg-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libboost-dev python3-dev
}

function sources_cgenius() {
    gitPullOrClone "$md_build" https://gitlab.com/Dringgstein/Commander-Genius.git stable

    # use -O2 on older GCC due to segmentation fault when compiling with -O3
    if compareVersions $__gcc_version lt 6.0.0; then
        sed -i "s/ADD_DEFINITIONS(-O3)/ADD_DEFINITIONS(-O2)/" src/CMakeLists.txt
    fi
}

function build_cgenius() {
    cmake -DUSE_SDL2=yes -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require="$md_build/src/CGeniusExe"
}

function install_cgenius() {
    md_ret_files=(
        'vfsroot'
        'src/CGeniusExe'
    )
}

function configure_cgenius() {
    addPort "$md_id" "cgenius" "Commander Genius" "pushd $md_inst; ./CGeniusExe; popd"

    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.CommanderGenius"  "$md_conf_root/$md_id"
    moveConfigDir "$md_conf_root/$md_id/games"  "$romdir/ports/$md_id"
}
