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
rp_module_flags="nobin"

function install_kodi() {
    # remove old repository - we will use Kodi from the Raspbian repositories
    rm -f /etc/apt/sources.list.d/mene.list
    aptInstall kodi
}

function configure_kodi() {
    echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules

    mkRomDir "ports"

    addPort "$md_id" "kodi" "Kodi" "kodi-standalone"
}
