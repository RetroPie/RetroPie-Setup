#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openmsx"
rp_module_desc="MSX emulator OpenMSX"
rp_module_menus="4+"
rp_module_flags="!mali"

function depends_openmsx() {
    getDepends libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev
}

function sources_openmsx() {
    gitPullOrClone "$md_build" https://github.com/openMSX/openMSX.git
    sed -i "s|INSTALL_BASE:=/opt/openMSX|INSTALL_BASE:=$md_inst|" build/custom.mk
    sed -i "s|SYMLINK_FOR_BINARY:=true|SYMLINK_FOR_BINARY:=false|" build/custom.mk
}

function build_openmsx() {
    rpSwap on 512
    ./configure
    make clean
    make
    rpSwap off
}

function install_openmsx() {
    make install
    mkdir -p "$md_inst/share/systemroms/"
    wget -q -O- "$__archive_url/openmsxroms.tar.gz" | tar -xvz -C "$md_inst/share/systemroms/"
}

function configure_openmsx() {
    mkRomDir "msx"

    addSystem 0 "$md_id" "msx" "$md_inst/bin/openmsx %ROM%"
}
