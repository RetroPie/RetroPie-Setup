#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="kodi"
rp_module_desc="Kodi - Open source home theatre software"
rp_module_menus="4+"
rp_module_flags="nobin !mali"

function depends_kodi() {
    if isPlatform "rpi"; then
        if [[ "$__depends_mode" == "install" ]]; then
            # remove old repository
            rm -f /etc/apt/sources.list.d/mene.list
            echo "deb http://dl.bintray.com/pipplware/dists/jessie/main/binary/ ./" >/etc/apt/sources.list.d/pipplware.list
            wget -q -O- http://pipplware.pplware.pt/pipplware/key.asc | apt-key add - >/dev/null
        else
            rm -f /etc/apt/sources.list.d/pipplware.list
            apt-key del 4096R/BAA567BB >/dev/null
        fi
    fi
}

function install_kodi() {
    aptInstall kodi
}

function remove_kodi() {
    aptRemove kodi
}

function configure_kodi() {
    # remove old directLaunch entry
    delSystem "$md_id" "kodi"

    addPort "$md_id" "kodi" "Kodi" "kodi-standalone"

    if [[ ! -f /etc/udev/rules.d/99-input.rules ]]; then
        echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules
    fi
}
