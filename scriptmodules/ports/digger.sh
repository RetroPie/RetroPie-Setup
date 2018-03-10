#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="digger"
rp_module_desc="Digger Remastered"
rp_module_licence="GPL https://raw.githubusercontent.com/sobomax/digger/master/README.md"
rp_module_section="exp"

function depends_digger() {
    getDepends cmake libsdl2-dev zlib1g-dev
}

function sources_digger() {
    gitPullOrClone "$md_build" https://github.com/proyvind/digger.git joystick
}

function build_digger() {
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst"
    make
    md_ret_require="$md_build/digger"
}

function install_digger() {
    md_ret_files=(
        'digger'
    )
}

function configure_digger() {
    # remove symlink that isn't used
    rm -f "$home/.config/digger"

    # symlink config and hiscore save file
    moveConfigFile "$home/.digger.rc" "$md_conf_root/digger/.digger.rc"
    moveConfigFile "$home/.digger.sco" "$md_conf_root/digger/.digger.sco"
    addPort "$md_id" "digger" "Digger Remastered" "$md_inst/digger /F"
}
