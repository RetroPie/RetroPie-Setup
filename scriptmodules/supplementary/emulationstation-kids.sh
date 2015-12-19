#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation-kids"
rp_module_desc="EmulationStation - Parental Control Edition (Experimental)"
rp_module_menus="4+"

function depends_emulationstation-kids() {
    getDepends \
        libboost-locale-dev libboost-system-dev libboost-filesystem-dev libboost-date-time-dev \
        libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev \
        libasound2-dev cmake libsdl2-dev
}
function sources_emulationstation-kids() {
    gitPullOrClone "$md_build" "https://github.com/zigurana/EmulationStation" "UI_modes_Kiosk_Kid_Full"
}

function build_emulationstation-kids() {
    rpSwap on 512
    cmake . -DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/emulationstation"
}

function install_emulationstation-kids() {
    md_ret_files=(
        'CREDITS.md'
        'emulationstation'
        'GAMELISTS.md'
        'README.md'
        'THEMES.md'
    )
}

function configure_inputconfig_emulationstation-kids() {
    mkUserDir "$home/.emulationstation"
    cat > "$home/.emulationstation/es_input.cfg" << _EOF_
<?xml version="1.0"?>
<inputList>
  <inputAction type="onfinish">
    <command>/opt/retropie/supplementary/emulationstation-kids/scripts/inputconfiguration.sh</command>
  </inputAction>
</inputList>
_EOF_
    chown $user:$user "$home/.emulationstation/es_input.cfg"
    mkdir -p "$md_inst/scripts"

    cp -rv "$scriptdir/scriptmodules/supplementary/emulationstation/"* "$md_inst/scripts/"
    chmod +x "$md_inst/scripts/inputconfiguration.sh"
    chown -R $user:$user "$md_inst/scripts"
}

function configure_emulationstation-kids() {
    cat > /usr/bin/emulationstation << _EOF_
#!/bin/bash

es_bin="$md_inst/emulationstation"

if [[ \$(id -u) -eq 0 ]]; then
    echo "emulationstation should not be run as root. If you used 'sudo emulationstation' please run without sudo."
    exit 1
fi

if [[ -n "\$(pidof X)" ]]; then
    echo "X is running. Please shut down X in order to mitigate problems with loosing keyboard input. For example, logout from LXDE."
    exit 1
fi

key=""
while [[ -z "\$key" ]]; do
    \$es_bin "\$@"
    echo "EmulationStation will restart in 5 seconds. Press a key to exit back to console."
    IFS= read -s -t 5 -N 1 key </dev/tty
done
_EOF_
    chmod +x /usr/bin/emulationstation

    # make sure that ES has enough GPU memory
    iniConfig "=" "" /boot/config.txt
    iniSet "gpu_mem_256" 128
    iniSet "gpu_mem_512" 256
    iniSet "gpu_mem_1024" 256
    iniSet "overscan_scale" 1

    mkdir -p "/etc/emulationstation"

    configure_inputconfig_emulationstation-kids
}
