#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lincity-ng"
rp_module_desc="lincity-ng - Open Source City Building Game"
rp_module_menus="4+"
rp_module_flags="nobin !mali"

function depends_lincity-ng() {
    getDepends xorg
}

function install_lincity-ng() {
    aptInstall lincity-ng
}

function configure_lincity-ng() {
    addPort "$md_id" "lincity-ng" "LinCity-NG" "xinit lincity-ng"
    moveConfigDir "$home/.lincity-ng" "$configDir/lincity-ng"
}
