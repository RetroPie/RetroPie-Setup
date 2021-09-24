#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="meritous"
rp_module_desc="Meritous"
rp_module_licence="GPL3 https://github.com/TurBoss/meritous/blob/master/gpl.txt"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_meritous() {
    getDepends  libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev
}

function sources_meritous() {
    gitPullOrClone "$md_build" https://github.com/TurBoss/meritous.git
}

function build_meritous() {
    make
    md_ret_require="$md_build/meritous"
}

function install_meritous() {
    md_ret_files=(
       'dat'
       'meritous'
    )
}

function configure_meritous() {
    chown pi:pi "$md_inst"
    mkRomDir "ports"

    addPort "$md_id" "meritous" "Meritous 1.2" "pushd $md_inst; ./meritous; popd"
}
