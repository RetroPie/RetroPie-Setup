#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="moonlight"
rp_module_desc="Gamestream client for embedded systems"
rp_module_section="exp"
#rp_module_flags="!x11 !mali"

function depends_moonlight() {
    local depends=(libopus-dev libexpat1-dev libasound2-dev libudev-dev libavahi-client3 libavahi-client-dev libcurl4-openssl-dev libevdev-dev libenet-dev uuid-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_moonlight() {
    gitPullOrClone "$md_build/moonlight" https://github.com/irtimmer/moonlight-embedded.git
    git submodule update --init

    mkdir cmake
    wget -q -O- "https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz" | tar -xvz --strip-components=1 -C cmake
}

function build_moonlight() {
    #cd cmake
    #./bootstrap
    #make
    #cd ..

    mkdir -p build
    cd build

    ../cmake/bin/cmake ../moonlight
    make
}

function configure_moonlight() {
    addPort "$md_id-720@60" "$md_id" "Moonlight" "$md_inst/moonlight stream -720 -60fps -app Steam"
    addPort "$md_id-1080@30" "$md_id" "Moonlight" "$md_inst/moonlight stream -1080 -30fps -app Steam"
    addPort "$md_id-1080@60" "$md_id" "Moonlight" "$md_inst/moonlight stream -1080 -60fps -app Steam"
}

function gui_moonlight() {
    local cmd=(dialog --backtitle "Moonlight Embedded Configuration" --inputbox "Enter IP address of PC (leave blank to auto-discover):" 8 40)
    local ip="$("${cmd[@]}" 2>&1 >/dev/tty)"

    "$md_inst/moonlight" pair "$ip"
}

