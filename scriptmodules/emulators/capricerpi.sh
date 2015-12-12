#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="capricerpi"
rp_module_desc="Amstrad CPC emulator - port of Caprice32 for the RPI"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_capricerpi() {
    getDepends libsdl1.2-dev zlib1g-dev
}

function sources_capricerpi() {
    gitPullOrClone "$md_build" https://github.com/KaosOverride/CapriceRPI.git
}

function build_capricerpi() {
    cd src
    make clean

    make RELEASE=TRUE
    md_ret_require="$md_build/src/capriceRPI"
}

function install_capricerpi() {
    cp -Rv "$md_build/"{README*.txt,COPYING.txt} "$md_inst/"
    cp -Rv "$md_build/src/capriceRPI" "$md_inst/"
}

function configure_capricerpi() {
    mkRomDir "amstradcpc"

    addSystem 0 "$md_id" "amstradcpc" "$md_inst/capriceRPI %ROM%"
}
