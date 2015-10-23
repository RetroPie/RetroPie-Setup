#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# http://www.gtkdb.de/index_36_2176.html
rp_module_id="kodi"
rp_module_desc="Install Kodi"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_kodi() {
    getDepends libcec1 libcec2
    echo "deb http://archive.mene.za.net/raspbian wheezy contrib" > /etc/apt/sources.list.d/mene.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
}

function install_kodi() {
    aptInstall kodi
}

function configure_kodi() {
    echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules

    mkRomDir "ports"

    addPort "Kodi" << _EOF_
#!/bin/bash
/opt/retropie/supplementary/runcommand/runcommand.sh 0 "kodi-standalone" "kodi"
_EOF_
}
