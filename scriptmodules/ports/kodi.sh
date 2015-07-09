#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
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
    echo "deb http://archive.mene.za.net/raspbian wheezy contrib" > /etc/apt/sources.list.d/mene.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
}

function install_kodi() {
    aptInstall kodi
}

function configure_kodi() {
    echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules

    mkRomDir "kodi"


    # Install kodi simple theme
    mkdir -p /etc/emulationstation/themes/simple/kodi/art
    cd /etc/emulationstation/themes/simple/kodi

    wget https://github.com/cschlonsok/retropie-kodi-installer/archive/1.0.zip

    unzip 1.0.zip

    cd retropie-kodi-installer-1.0/
    cp -v theme.xml ../
    cp -v kodi_background.jpg ../art/
    cp -v kodi_icon.png ../art/

    cd ..
    rm 1.0.zip



    cat > "$romdir/kodi/Kodi.sh" << _EOF_
#!/bin/bash
/opt/retropie/supplementary/runcommand/runcommand.sh 0 "kodi-standalone" "kodi"
_EOF_

    chmod +x "$romdir/kodi/Kodi.sh"

    # Add System to es_system.cfg
    setESSystem 'Kodi' 'kodi' '~/RetroPie/roms/kodi' '.sh .SH' '%ROM%' 'pc' 'kodi'
}
