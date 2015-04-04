#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="inputstation"
rp_module_desc="InputStation"
rp_module_menus="2+"

function depends_inputstation() {
    getDepends \
        libboost-locale-dev libboost-system-dev libboost-filesystem-dev libboost-date-time-dev \
        libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev \
        libasound2-dev cmake libsdl2-dev
}

function sources_inputstation() {
    gitPullOrClone "$md_build" "https://github.com/petrockblog/InputStation"
}

function build_inputstation() {
    rpSwap on 512
    cd program
    cmake . -DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/
    make clean
    make
    cd ..
    rpSwap off
    md_ret_require="$md_build/program/inputstation"
}

function install_inputstation() {
    mkdir -p "$md_inst/"{program,script,script/configscripts}
    cp "$md_build/program/inputstation" "$md_inst/program/"
    cp "$md_build/script/inputconfiguration.sh" "$md_inst/script/"
    cp "$md_build/script/configscripts/retroarch.sh" "$md_inst/script/configscripts/"
    cp "$md_build/script/configscripts/emulationstation.sh" "$md_inst/script/configscripts/"
    chown "$user":"$user" -R "$md_inst/"{program,script}

    md_ret_files=(
        'CREDITS.md'
        'LICENSE.md'
        'README.md'
    )
}
