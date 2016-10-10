#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
# @autor: Nyaran
# @date: 2016/10/09
# @usage: Place this script into RetroPie-Setup/scriptmodules/supplementary directory and execute the following command:
#         `sudo RetroPie-Setup/retropie_packages.sh moonlight-embedded`
#         Also you can use the setup script. the installer is located under *exp packages* option.


rp_module_id="moonlight-embedded"
rp_module_desc="Moonlight Embedded Game Streaming"
rp_module_section="exp"

function depends_moonlight-embedded() {
    getDepends libopus0 libexpat1 libasound2 libudev0 libavahi-client3 libcurl3 libevdev2 libenet7 libraspberrypi0 libssl-dev libopus-dev libasound2-dev libudev-dev libavahi-client-dev libcurl4-openssl-dev libevdev-dev libexpat1-dev libpulse-dev uuid-dev libenet-dev
}

function sources_moonlight-embedded() {
    gitPullOrClone "$md_build/installer" "https://github.com/Nyaran/RetropieMoonlightInstaller.git"
    gitPullOrClone "$md_build/moonlight" "https://github.com/irtimmer/moonlight-embedded.git"
}

# Compile CMake 3.1+ until is not available on Raspbian repositories
function build_cmake() {
    wget https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz
    tar -xvf cmake-3.6.2.tar.gz
    rm cmake-3.6.2.tar.gz
    pushd cmake-3.6.2/
    ./bootstrap
    make
    popd
}

function build_moonlight-embedded() {
    build_cmake

    pushd moonlight
    git submodule update --init
    mkdir build
    cd build/

    ../../cmake-3.6.2/bin/cmake ../
    make
    popd
}

function install_moonlight-embedded() {
    # Install moonlight-embedded simple theme
    mkdir -p /etc/emulationstation/themes/simple/moonlight-embedded/art
    cp -v "$md_build/installer/themes/simple/theme.xml" /etc/emulationstation/themes/simple/moonlight-embedded/theme.xml
    cp -v "$md_build/installer/themes/simple/art/icon.png" /etc/emulationstation/themes/simple/moonlight-embedded/art/icon.png
    cp -v "$md_build/installer/themes/simple/art/logo.png" /etc/emulationstation/themes/simple/moonlight-embedded/art/logo.png
    cp -v "$md_build/installer/themes/simple/art/background.png" /etc/emulationstation/themes/simple/moonlight-embedded/art/background.png

    # Install moonlight-embedded carbon theme
    mkdir -p /etc/emulationstation/themes/carbon/moonlight-embedded/art
    cp -v "$md_build/installer/themes/carbon/theme.xml" /etc/emulationstation/themes/carbon/moonlight-embedded/theme.xml
    cp -v "$md_build/installer/themes/carbon/art/system.svg" /etc/emulationstation/themes/carbon/moonlight-embedded/art/system.svg
    cp -v "$md_build/installer/themes/carbon/art/controller.svg" /etc/emulationstation/themes/carbon/moonlight-embedded/art/controller.svg

    md_ret_files=(
        'moonlight/build/moonlight'
        'moonlight/build/libmoonlight-pi.so'
        'moonlight/build/libgamestream/libgamestream.so'
        'moonlight/build/libgamestream/libgamestream.so.0'
        'moonlight/build/libgamestream/libgamestream.so.2.2.2'
        'moonlight/build/libgamestream/libmoonlight-common.so'
        'moonlight/build/libgamestream/libmoonlight-common.so.0'
        'moonlight/build/libgamestream/libmoonlight-common.so.2.2.2'
        'moonlight/build/docs'
    )
}

function configure_moonlight-embedded() {
    # Create romdir moonlight embedded
    mkRomDir "moonlight-embedded"

    # Add System to es_system.cfg
    addSystem 1 "$md_id" "moonlight-embedded" "%ROM%" "$rp_module_desc" ".sh .SH"

    [[ "$md_mode" == "remove" ]] && return

    # Create moonlight embedded config script
    cat > "$romdir/moonlight-embedded/moonlight-embedded_config.sh" << _EOF_
#!/bin/bash
sudo $scriptdir/retropie_packages.sh moonlight-embedded configure
_EOF_

    gui_moonlight-embedded

    # Remove existing scripts if they exist & Create scripts for running moonlight-embedded from emulation station
    cat > "$romdir/moonlight-embedded/moonlight-embedded_720p60fps.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./moonlight stream -720 -60fps -app Steam
popd
_EOF_

    cat > "$romdir/moonlight-embedded/moonlight-embedded_1080p30fps.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./moonlight stream -1080 -30fps -app Steam
popd
_EOF_

    cat > "$romdir/moonlight-embedded/moonlight-embedded_1080p60fps.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./moonlight stream -1080 -60fps -app Steam
popd
_EOF_

    # Chmod scripts to be runnable
    chmod +x "$romdir/moonlight-embedded/"*.sh
}

function gui_moonlight-embedded() {
    pushd "$md_inst"

    local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --inputbox "Input ip-address of GeForce PC (left blank to auto-discover):" 8 40)
    local ip=$("${cmd[@]}" 2>&1 >/dev/tty)

    # FIXME Show PIN in dialog
    #local pair_text=`{ error=$(./moonlight pair 2>&1 1>&3- )  ;} & 3>&1 `
    #local end=(dialog --backtitle "Moonlight Embedded Configuration" --msgbox "${pair_text}" 10 100)
    #$("${end[@]}" 2>&1 >/dev/tty)

    ./moonlight pair $ip

    popd
}
