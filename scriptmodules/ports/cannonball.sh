#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cannonball"
rp_module_desc="cannonball - An Enhanced OutRun Engine"
rp_module_menus="4+"
rp_module_flags=""

function depends_cannonball() {
    getDepends libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libboost-dev
}

function sources_cannonball() {
    gitPullOrClone "$md_build" https://github.com/VanFanel/cannonball.git
}

function build_cannonball() {
    mkdir build
    cd build
    cmake -DTARGET=sdl2_rpi -DCMAKE_INSTALL_PREFIX:PATH="$md_inst" ../cmake
    make
}

function install_cannonball() {
    cp build/cannonball "$md_inst"
    mkdir "$md_inst/roms/"
    mkdir "$md_inst/res/"
    cp -R roms/* "$md_inst/roms/"
    cp res/tilemap.bin "$md_inst/res/"
    cp res/tilepatch.bin "$md_inst/res/"
    cp res/config.xml "$md_inst"
    touch "$md_inst/hiscores.xml"
    chown pi:pi "$md_inst/"
    chown pi:pi "$md_inst/cannonball"
    chown pi:pi "$md_inst/config.xml"
    chown pi:pi "$md_inst/hiscores.xml"
    chown pi:pi "$md_inst/res"
    chown pi:pi "$md_inst/roms"
    chown pi:pi "$md_inst/res/tilemap.bin"
    chown pi:pi "$md_inst/res/tilepatch.bin"
}

function configure_cannonball() {
    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "$md_inst/cannonball"
    __INFMSGS+=("You need to unzip your OutRun set B from latest MAME (outrun.zip) to $md_inst/cannonball/roms. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work.")
}
