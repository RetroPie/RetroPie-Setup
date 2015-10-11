#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="osmose"
rp_module_desc="Gamegear emulator Osmose"
rp_module_menus="2+"

function depends_osmose() {
    getDepends libsdl1.2-dev
}

function sources_osmose() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/osmose-rpi.git
}

function build_osmose() {
    make clean
    # not safe for building in parallel
    make -j1
    md_ret_require="$md_build/osmose"
}

function install_osmose() {
    md_ret_files=(
        'changes.txt'
        'license.txt'
        'osmose'
    )
}

function configure_osmose() {
    mkRomDir "gamegear"
    mkRomDir "mastersystem"

    delSystem "$md_id" "gamegear-osmose"
    delSystem "$md_id" "mastersystem-osmose"
    addSystem 0 "$md_id" "gamegear" "$md_inst/osmose %ROM% -tv -fs"
    addSystem 0 "$md_id" "mastersystem" "$md_inst/osmose %ROM% -tv -fs"
}
