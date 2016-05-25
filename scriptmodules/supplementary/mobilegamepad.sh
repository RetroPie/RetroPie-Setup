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
rp_module_desc="Setting up a Mobile Gamepad on mobilephone (WIFI)"
rp_module_menus="4+"

function install_mobilegamepad() {
    # Install nodejs
    curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
    apt-get install -y nodejs
    # Install Grunt Command Line Interface
    npm install -g grunt-cli
    # Clone project MobileGamePad and install dependencies
    gitPullOrClone "$md_inst" https://github.com/sbidolach/mobile-gamepad.git
    cd "$md_inst"
    npm install --unsafe-perm
    # Enable Mobile gamepad on startup
    npm install --unsafe-perm pm2 -g
    pm2 start app.sh
    pm2 startup
    pm2 save
}
