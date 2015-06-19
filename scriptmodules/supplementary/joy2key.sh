#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="joy2key"
rp_module_desc="joy2key - send keyboard presses with a joystick"
rp_module_menus="2+ 3+"
rp_module_flags=""

function sources_joy2key() {
    gitPullOrClone "$md_build" "https://github.com/RetroPie/joy2key.git"
}

function build_joy2key() {
    autoreconf -if
    ./configure --prefix="$md_inst"
}

function install_joy2key() {
    make clean
    make
    make install
}
