#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="limelight"
rp_module_desc="Limelight Game Streaming"
rp_module_menus="4+"

function depends_limelight() {
    getDepends oracle-java8-jdk input-utils
}

function sources_limelight() {
    gitPullOrClone "$md_build" "https://github.com/stsfin/RetropieLimelightInstaller.git"
    
    wget https://github.com/irtimmer/limelight-embedded/releases/download/v1.2.2/libopus.so
    wget https://github.com/irtimmer/limelight-embedded/releases/download/v1.2.2/limelight.jar
    
    # Download limelight simple theme
    wget https://github.com/stsfin/RetropieLimelightInstaller/releases/download/1.3.1/theme.xml
    wget https://github.com/stsfin/RetropieLimelightInstaller/releases/download/1.3.1/limelight.png
    wget https://github.com/stsfin/RetropieLimelightInstaller/releases/download/1.3.1/limelight_art.png
    wget https://github.com/stsfin/RetropieLimelightInstaller/releases/download/1.3.1/limelight_art_blur.png
}

function install_limelight() {
    md_ret_files=(
        'libopus.so'
        'limelight.jar'
        'README.md'
        'limelightRetroInstall.sh'
        'limelightconfig.sh'
        'theme.xml'
        'limelight.png'
        'limelight_art.png'
        'limelight_art_blur.png'
    )
}

function configure_limelight() { 
    # Create romdir limelight
    mkRomDir "limelight"

    # Create limelight config script
    cat > "$romdir/limelight/limelightconfig.sh" << _EOF_
#!/bin/bash
$scriptdir/retropie_packages.sh limelight configure
_EOF_

    # Install limelight simple theme
    mkdir -p /etc/emulationstation/themes/simple/limelight/art
    cp -v "$md_inst/theme.xml" /etc/emulationstation/themes/simple/limelight/
    cp -v "$md_inst/limelight.png" /etc/emulationstation/themes/simple/limelight/art/
    cp -v "$md_inst/limelight_art.png" /etc/emulationstation/themes/simple/limelight/art/
    cp -v "$md_inst/limelight_art_blur.png" /etc/emulationstation/themes/simple/limelight/art/

    # Run limelight configuration
    pushd "$md_inst"
    clear
    echo "Discovering GeForce PCs, when found you can press ctrl+c to stop the search, or it will take a long time"
    # discover IP-addresses of Geforce pc:s
    java -jar limelight.jar discover
    echo
    # ask user for IP-number input for pairing
    local ip
    read -p $'Input ip-address given above (if no IP is shown, press CTRL+C and check host connection) :\n> ' ip
    # pair pi with geforce experience
    java -jar limelight.jar pair $ip
    read -n1 -s -p "Press any key to continue after you have given the passcode to the Host PC..."
    read -n1 -s -p "Please ensure that your gamepad is connected to the PI for device selection (number only!), press any key to continue..."
    clear
    # print eventID-numbers and device names with lsinput
    lsinput | grep -e "/dev/input/event" -e "name"
    # ask user for eventID number for keymapping
    local usbid
    echo
    echo "Input device event ID-number that corresponds with your gamepad from above for keymapping"
    read -p $'(if the gamepad is missing, press CTRL+C and reboot the PI with the game pad attached) :\n> ' usbid
    # run limelight keymapping
    java -jar limelight.jar map -input /dev/input/event$usbid mapfile.map
    popd

    # Remove existing scripts if they exist & Create scripts for running limelight from emulation station
    cat > "$romdir/limelight/limelight720p60fps.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
java -jar limelight.jar stream -720 -60fps "$ip" -app Steam -mapping mapfile.map
popd
_EOF_

    cat > "$romdir/limelight/limelight1080p30fps.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
java -jar limelight.jar stream -1080 -30fps "$ip" -app Steam -mapping mapfile.map
popd
_EOF_

    cat > "$romdir/limelight/limelight1080p60fps.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
java -jar limelight.jar stream -1080 -60fps "$ip" -app Steam -mapping mapfile.map
popd
_EOF_

    # Chmod scripts to be runnable
    chmod +x "$romdir/limelight/"*.sh

    # Add System to es_system.cfg
    setESSystem 'Limelight Game Streaming' 'limelight' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'limelight'

    echo -e "\nEverything done! Now reboot the Pi and you are all set \n"
}
