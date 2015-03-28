#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="openmsx"
rp_module_desc="MSX emulator OpenMSX"
rp_module_menus="4+"

function depends_openmsx() {
    getDepends libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev
}

function sources_openmsx() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/openmsx-0.10.0.tar.gz | tar -xvz --strip-components=1
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
    wget "http://downloads.petrockblock.com/retropiearchives/openmsxroms.zip"
    mkdir -p "$md_inst/share/systemroms/"
    unzip openmsxroms.zip -o -d "$md_inst/share/systemroms/"
}

function configure_openmsx() {
    mkRomDir "msx"

    addSystem 0 "$md_id" "msx" "$md_inst/bin/openmsx -cart %ROM%"
}
