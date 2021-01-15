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
rp_module_licence="MIT https://raw.githubusercontent.com/miroof/node-virtual-gamepads/master/LICENSE"
rp_module_section="exp"
rp_module_flags="noinstclean nobin"

function depends_virtualgamepad() {
    getDepends nodejs npm
}

function remove_virtualgamepad() {
    pm2 stop main
    pm2 delete main
    rm -f /etc/apt/sources.list.d/nodesource.list
}

function sources_virtualgamepad() {
    gitPullOrClone "$md_inst" https://github.com/miroof/node-virtual-gamepads.git
    chown -R $user:$user "$md_inst"
}

function install_virtualgamepad() {
    npm install pm2 -g --unsafe-perm
    cd "$md_inst"
    sudo -u $user npm install
    sudo -u $user npm install ref
}

function configure_virtualgamepad() {
    [[ "$md_mode" == "remove" ]] && return
    pm2 start main.js
    pm2 startup
    pm2 save
}
