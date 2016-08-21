#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dolphin"
rp_module_desc="Gamecube/Wii emulator Dolphin"
rp_module_help="ROM Extensions: .iso\n\nCopy your gamecube roms to $romdir/gamecube and Wii roms to $romdir/wii"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_dolphin() {
    hasPackage dolphin-emu && dpkg --remove dolphin-emu
    local depends=(cmake pkg-config git libao-dev libasound2-dev libavcodec-dev libavformat-dev libbluetooth-dev libenet-dev libgtk2.0-dev liblzo2-dev libminiupnpc-dev libopenal-dev libpulse-dev libreadline-dev libsfml-dev libsoil-dev libsoundtouch-dev libswscale-dev libusb-1.0-0-dev libwxbase3.0-dev libwxgtk3.0-dev libxext-dev libxrandr-dev portaudio19-dev zlib1g-dev libudev-dev libevdev-dev libmbedtls-dev libcurl4-openssl-dev libegl1-mesa-dev)
    getDepends "${depends[@]}"
}

function sources_dolphin() {
    gitPullOrClone "$md_build" https://github.com/dolphin-emu/dolphin.git
}

function build_dolphin() {
    mkdir Build && cd Build
    cmake .. -DENABLE_HEADLESS=1
    make
}

function install_dolphin() {
    cd Build
    make install
}

function configure_dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    addSystem 1 "${md_id}" "gc" "dolphin-emu -b -e %ROM%"
    addSystem 1 "${md_id}" "wii" "dolphin-emu -b -e %ROM%"
}
