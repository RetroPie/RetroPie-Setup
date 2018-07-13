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
rp_module_licence="GPL2 https://raw.githubusercontent.com/STJr/SRB2/master/LICENSE"
rp_module_section="exp"

function depends_srb2() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev
}

function sources_srb2() {
    gitPullOrClone "$md_build" https://github.com/STJr/SRB2.git
    downloadAndExtract "$__archive_url/srb2-assets.tar.gz" "$md_build"
}

function build_srb2() {
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require="$md_build/build/bin/srb2"
}

function install_srb2() {
    # copy and dereference, so we get a srb2 binary rather than a symlink to srb2-version
    cp -L 'build/bin/srb2' "$md_inst/srb2"
    md_ret_files=(
        'assets/music.dta'
        'assets/patch.dta'
        'assets/player.dta'
        'assets/rings.dta'
        'assets/zones.dta'
        'assets/srb2.srb'
    )
}

function configure_srb2() {
    addPort "$md_id" "srb2" "Sonic Robo Blast 2" "pushd $md_inst; ./srb2; popd"

    moveConfigDir "$home/.srb2"  "$md_conf_root/$md_id"
}
