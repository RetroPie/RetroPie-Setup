#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="esconfig"
rp_module_desc="ES-Config"
rp_module_menus=""
rp_module_flags="nobin"

function sources_esconfig() {
    gitPullOrClone "$md_build" git://github.com/Aloshi/ES-config.git
    sed -i -e "s/apt-get install/apt-get install -y --force-yes/g" get_dependencies.sh  
    ./get_dependencies.sh
}

function build_esconfig()
{
    make clean
    make
    md_ret_require="$md_build/es-config"
}

function install_esconfig()
{
    md_ret_files=(
        'CREDITS.md'
        'es-config'
        'README.md'
        'resources'
        'SCRIPTING.md'
        'scripts'
    )
}

function configure_esconfig()
{
    cp "$scriptdir/supplementary/settings.xml" "$md_inst/"
    sed -i -e "s|/home/pi/RetroPie|$rootdir|g" "$md_inst/settings.xml"
    mkRomDir "esconfig"

    # generate new startup scripts for ES-config
    cp "$scriptdir/supplementary/scripts"/*/*.py "$romdir/esconfig/"
    chmod +x "$romdir/esconfig"/*.py
    chown $user:$user "$romdir/esconfig/"*

    # add some information
    mkdir -p "$home/.emulationstation/gamelists/esconfig/"
    cat > "$home/.emulationstation/gamelists/esconfig/gamelist.xml" << _EOF_
<?xml version="1.0"?>
<gameList>
    <game>
        <path>$romdir/esconfig/esconfig.py</path>
        <name>Start ES-Config</name>
        <desc>[DGen]
Old Genesis/Megadrive emulator

[RetroArch]
GB,GBC,NES,SNES,MASTERSYSTEM,GENESIS/MEGADRIVE,PSX

[GnGeo]
Old NeoGeo emulator
GNGEO 0.7</desc>
    </game>
    <game>
        <path>$romdir/esconfig/basic.py</path>
        <name>Update Retroarch Autoconfig (Keyboard necessary)</name>
        <desc>Joypad config will be stored under /opt/retropie/emulators/retroarch/configs.</desc>
    </game>
    <game>
        <path>$romdir/esconfig/autoon.py</path>
        <name>Enable RetroArch Autoconfig</name>
    </game>
    <game>
        <path>$romdir/esconfig/autooff.py</path>
        <name>Disable RetroArch Autoconfig</name>
    </game>
    <game>
        <path>$romdir/esconfig/rgui.py</path>
        <name>Open RGUI</name>
        <desc>RetroArch Menu. (X = ok, Y/Z = cancel). Select "Save On Exit" to store changes.</desc>
    </game>
    <game>
        <path>$romdir/esconfig/showip.py</path>
        <name>Show current IP address</name>
    </game>
</gameList>
_EOF_

}
