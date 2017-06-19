#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="supacec"
rp_module_desc="Adds some much needed HDMI-CEC awareness, hopefully this package will drum up some desire for the feature and some better developers will help flesh this out. PRs are accepted! At the moment, this will send a CEC switch input command when new input devices are discovered in /dev/input i.e. turning on and pairing a controller."
rp_module_licence="GPL3"
rp_module_section="exp"
rp_module_flags="!x11"

function depends_supacec() {
    getDepends cec-utils
}

function sources_supacec() {
    gitPullOrClone "$md_build" "https://github.com/superterran/SupaCEC.git" 

}

function remove_supacec() {
    sudo update-rc.d -f supacec remove
    sudo /etc/init.d/supacec stop
    sudo rm -f /usr/bin/supacec 
    sudo rm -f /etc/init.d/supacec
}

function install_supacec() {
    sudo cp "$md_build/supacec.d" /etc/init.d/supacec
    sudo cp "$md_build/supacec" /usr/bin/supacec
    sudo chmod +x /usr/bin/supacec
    sudo chmod +x /etc/init.d/supacec
    sudo update-rc.d supacec defaults
    sudo /etc/init.d/supacec start

}
