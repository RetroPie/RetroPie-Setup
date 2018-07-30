#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="bombermaaan"
rp_module_desc="Bombermaaan - Classic bomberman game"
rp_module_licence="GPL3 https://github.com/bjaraujo/Bombermaaan/blob/master/LICENSE.txt"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_bombermaaan() {
    getDepends cmake libsdl1.2-dev libsdl-mixer1.2-dev build-essential
}

function sources_bombermaaan() {
    gitPullOrClone "$md_build" https://github.com/bjaraujo/Bombermaaan.git
}

function build_bombermaaan() {
    cd trunk
    cmake . -DCMAKE_INSTALL_PREFIX="$md_inst" -DLOAD_RESOURCES_FROM_FILES:BOOL=ON
    make
    mv src/Bombermaaan bombermaaan
    md_ret_require="$md_build/trunk/bombermaaan"
}

function install_bombermaaan() {
    md_ret_files=(        
        'trunk/bombermaaan'
        'trunk/levels'
        'trunk/res/images'
        'trunk/res/sounds'
    )
}

function configure_bombermaaan() {
    addPort "$md_id" "bombermaaan" "Bombermaaan" "pushd $md_inst; $md_inst/bombermaaan; popd"
}
