#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="virtualgamepad"
rp_module_desc="Virtual Gamepad for Smartphone"
rp_module_menus="4+"

function install_virtualgamepad() {
    wget http://node-arm.herokuapp.com/node_latest_armhf.deb
    dpkg -i node_latest_armhf.deb
    rm node_latest_armhf.deb
    gitPullOrClone $md_inst https://github.com/miroof/node-virtual-gamepads.git
    cd $md_inst
    npm install --unsafe-perm
    npm install --unsafe-perm pm2 -g
    pm2 start main.js
    pm2 startup
    pm2 save
}