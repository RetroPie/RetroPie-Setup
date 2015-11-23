#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wolf4sdl"
rp_module_desc="Wolf4SDL, port of Wolfenstein 3D Shareware 1.4 version"
rp_module_menus="4+"
rp_module_flags="dispmanx"

function depends_wolf4sdl() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev
}

function sources_wolf4sdl() {
    gitPullOrClone "$md_build" https://github.com/mozzwald/wolf4sdl.git
    # Define Shareware version
    sed -i 's|#define GOODTIMES|//#define GOODTIMES|g' version.h
    
    # Define Steam version
    # sed -i 's|#define UPLOAD|//#define UPLOAD|g' version.h
    
    # Define 3D Realms version
    # sed -i 's|#define GOODTIMES|//#define GOODTIMES|g' version.h
    # sed -i 's|#define UPLOAD|//#define UPLOAD|g' version.h
}

function build_wolf4sdl() {
    make clean
    make DATADIR="$romdir/ports/wolf3d/"
    md_ret_require="$md_build"
}

function install_wolf4sdl() {
     mkdir -p "$md_inst/share/man/man6"
     make install PREFIX="$md_inst" MANPREFIX="$md_inst/share/man"
}

function configure_wolf4sdl() {
    mkRomDir "ports"
    mkRomDir "ports/wolf3d"

    # Get shareware game data
    wget -q -O wolf3d14.zip http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip
    unzip -j -o -LL wolf3d14.zip -d "$romdir/ports/wolf3d"
    rm -f wolf3d14.zip

    setDispmanx "$md_id" 1

    addPort "$md_id" "wolf4sdl" "Wolfenstein 3D" "$md_inst/bin/wolf3d"
}
