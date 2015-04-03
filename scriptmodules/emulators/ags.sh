#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="ags"
rp_module_desc="Adventure Game Studio - Adventure game engine"
rp_module_menus="4+"

function depends_ags() {
    getDepends pkg-config liballegro4.2-dev libaldmb1-dev libfreetype6-dev libtheora-dev libvorbis-dev libogg-dev
}

function sources_ags() {
    gitPullOrClone "$md_build" git://github.com/adventuregamestudio/ags.git
}

function build_ags() {
    make -C Engine clean
    make -C Engine
}

function install_ags() {
    make -C Engine PREFIX="$md_inst" install
}

function configure_ags() {
    mkRomDir "ags"
    
    addSystem 1 "$md_id" "ags" "xinit $md_inst/bin/ags --fullscreen %ROM%" "Adventure Game Studio" ".exe"
}