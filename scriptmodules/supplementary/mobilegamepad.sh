#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mobilegamepad"
rp_module_desc="Mobile Universal Gamepad for RetroPie"
rp_module_section="exp"

function depends_mobilegamepad() {
    getDepends nodejs npm
    if isPlatform "arm"; then
        wget -qO "$__tmpdir/node_latest_armhf.deb" http://node-arm.herokuapp.com/node_latest_armhf.deb
        dpkg -i "$__tmpdir/node_latest_armhf.deb"
        rm "$__tmpdir/node_latest_armhf.deb"
    fi
    npm install -g grunt-cli
    npm install --unsafe-perm pm2 -g
}

function sources_mobilegamepad() {
    gitPullOrClone "$md_inst" https://github.com/sbidolach/mobile-gamepad.git
}

function build_mobilegamepad() {
    cd "$md_inst"
    npm install --unsafe-perm
}

function configure_mobilegamepad() {
    pm2 start app.sh
    pm2 startup
    pm2 save
}
