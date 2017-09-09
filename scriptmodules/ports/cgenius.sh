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
    getDepends build-essential clang-3.9 libvorbis-dev libogg-dev libsdl2-dev libsdl2-image-dev libboost-dev
}

function sources_cgenius() {
    downloadAndExtract "https://github.com/gerstrong/Commander-Genius/archive/v1992beta.tar.gz" "$md_build" 1
}

function build_cgenius() {
    cd $md_build
    CC=clang-3.9 CXX=clang++-3.9 cmake -DUSE_SDL2=yes -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require="$md_build"
}

function install_cgenius() {
    md_ret_files=(
        'hqp'
        'vfsroot/games'
        'src/Build/LINUX/CGeniusExe'
    )
}

function configure_cgenius() {
    addPort "$md_id" "cgenius" "Commander Genius" "pushd $md_inst; ./CGeniusExe; popd"

    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.CommanderGenius"  "$md_conf_root/$md_id"

    mv "$md_inst/games" "$romdir/ports/$md_id/"
    mv "$md_inst/hqp" "$romdir/ports/$md_id/"

    ln -snf "$romdir/ports/$md_id/games" "$md_inst"

    chown -R $user:$user "$romdir/ports/$md_id"
}
