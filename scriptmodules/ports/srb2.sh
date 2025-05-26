#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="srb2"
rp_module_desc="Sonic Robo Blast 2 - 3D Sonic the Hedgehog fan-game built using a modified version of the Doom Legacy source port of Doom"
rp_module_licence="GPL2 https://git.do.srb2.org/STJr/SRB2/-/raw/next/LICENSE?ref_type=heads"
rp_module_repo="git https://git.do.srb2.org/STJr/SRB2 :_get_branch_srb2"
rp_module_section="exp"

function _version_srb2() {
    echo "2.2.15"
}

function _get_branch_srb2() {
    echo "SRB2_release_$(_version_srb2)"
}

function depends_srb2() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev libgme-dev libpng-dev libcurl4-openssl-dev libopenmpt-dev
}

function sources_srb2() {
    gitPullOrClone
    local ver="$(_version_srb2)"
    ver=${ver//\./}
    downloadAndExtract "https://github.com/STJr/SRB2/releases/download/SRB2_release_$(_version_srb2)/SRB2-v${ver}-Full.zip" "$md_build/assets"
    # patch detection for CMake < 3.18
    if hasPackage cmake 3.18 lt; then
        applyPatch "$md_data/001-cmake-libfind.diff"
    fi
}

function build_srb2() {
    rm -fr build && mkdir build
    cd build

    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$md_inst" -DSRB2_SDL2_EXE_NAME=srb2
    make
    md_ret_require="$md_build/build/bin/srb2"
}

function install_srb2() {
    md_ret_files=(
        'build/bin/srb2'
        'assets/characters.pk3'
        'assets/srb2.pk3'
        'assets/music.pk3'
        'assets/zones.pk3'
        'assets/README.txt'
        'assets/LICENSE.txt'
    )
}

function configure_srb2() {
    addPort "$md_id" "srb2" "Sonic Robo Blast 2" "pushd $md_inst; ./srb2; popd"

    moveConfigDir "$home/.srb2"  "$md_conf_root/$md_id"
}
