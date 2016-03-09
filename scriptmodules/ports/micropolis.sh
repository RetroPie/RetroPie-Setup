#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="micropolis"
rp_module_desc="Micropolis - Open Source City Building Game"
rp_module_menus="4+"
rp_module_flags="nobin !mali !x86"

function depends_micropolis() {
    getDepends xorg matchbox
}

function install_micropolis() {
    aptInstall micropolis
}

function configure_micropolis() {
    mkRomDir "ports"

    addPort "$md_id" "micropolis" "Micropolis" "xset -dpms s off s noblank; matchbox-window-manager \&; xinit micropolis"
}
