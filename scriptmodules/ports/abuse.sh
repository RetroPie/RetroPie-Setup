#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="abuse"
rp_module_desc="Abuse"
rp_module_license="GPL https://raw.githubusercontent.com/Xenoveritas/abuse/master/COPYING"
rp_module_section="exp"

# abuse-lib & abuse-sfx will pull in the older abuse package which only works under X
function depends_abuse() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev abuse-lib abuse-sfx
}

function sources_abuse() {
    gitPullOrClone "$md_build" git://github.com/Xenoveritas/abuse
}

function build_abuse() {
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require="$md_build/src/abuse"
}

function install_abuse() {
    md_ret_files=(
        'src/abuse'
    )
}

function configure_abuse() {
    mkRomDir "ports"
    moveConfigDir "$home/.abuse" "$md_conf_root/abuse"
    addPort "$md_id" "abuse" "Abuse" "pushd $md_inst; $md_inst/abuse -datadir /usr/share/games/abuse/; popd"
}
