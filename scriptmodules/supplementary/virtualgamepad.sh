#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="virtualgamepad"
rp_module_desc="Virtual Gamepad for Smartphone"
rp_module_menus="4+"

function install_virtualgamepad() {
    wget http://node-arm.herokuapp.com/node_archive_armhf.deb
    dpkg -i node_archive_armhf.deb
    rm node_archive_armhf.deb
    gitPullOrClone "$md_inst" https://github.com/miroof/node-virtual-gamepads.git
    cd "$md_inst"
    npm install --unsafe-perm
    npm install --unsafe-perm pm2 -g
    pm2 start main.js
    pm2 startup
    pm2 save
}
