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
    getDepends nodejs
    # if the system version of nodejs is old or doesn't package npm, we will install manually for armv6 or use nodesource
    if hasPackage nodejs 4.6 lt || ! which npm >/dev/null; then
        if isPlatform "armv6"; then
            getDepends npm
            if ! hasPackage node; then
                wget -qO "$__tmpdir/node_latest_armhf.deb" http://node-arm.herokuapp.com/node_latest_armhf.deb
                dpkg -i "$__tmpdir/node_latest_armhf.deb"
                rm "$__tmpdir/node_latest_armhf.deb"
            fi
        else
            getDepends curl
            # remove any old node package - we will use nodesource
            hasPackage node && aptRemove node
            curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
            # force aptInstall to get a fresh list before installing
            __apt_update=0
            aptInstall nodejs
        fi
    fi
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
