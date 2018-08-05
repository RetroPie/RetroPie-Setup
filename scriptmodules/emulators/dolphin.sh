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
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz\n\nCopy your gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dolphin-emu/dolphin/master/license.txt"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_dolphin() {
    local depends=(cmake pkg-config libao-dev libasound2-dev libavcodec-dev libavformat-dev libbluetooth-dev libenet-dev libgtk2.0-dev liblzo2-dev libminiupnpc-dev libopenal-dev libpulse-dev libreadline-dev libsfml-dev libsoil-dev libsoundtouch-dev libswscale-dev libusb-1.0-0-dev libwxbase3.0-dev libwxgtk3.0-dev libxext-dev libxrandr-dev portaudio19-dev zlib1g-dev libudev-dev libevdev-dev libmbedtls-dev libcurl4-openssl-dev libegl1-mesa-dev qtbase5-private-dev)
    getDepends "${depends[@]}"
}

function sources_dolphin() {
    local branch="master"
    # current HEAD of dolphin doesn't build on Ubuntu 16.04 (with gcc 5.4)
    compareVersions $__gcc_version lt 6.0.0 && branch="5.0"

    gitPullOrClone "$md_build" https://github.com/dolphin-emu/dolphin.git "$branch"
}

function build_dolphin() {
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$md_inst"
    make clean
    make
    md_ret_require="$md_build/build/Binaries/dolphin-emu"
}

function install_dolphin() {
    cd build
    make install
}

function configure_dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    moveConfigDir "$home/.dolphin-emu" "$md_conf_root/gc"

    if [[ ! -f "$md_conf_root/gc/Config/Dolphin.ini" ]]; then
        mkdir -p "$md_conf_root/gc/Config"
        cat >"$md_conf_root/gc/Config/Dolphin.ini" <<_EOF_
[Display]
FullscreenResolution = Auto
Fullscreen = True
_EOF_
        chown -R $user:$user "$md_conf_root/gc/Config"
    fi

    addEmulator 1 "$md_id" "gc" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 0 "$md_id-gui" "gc" "$md_inst/bin/dolphin-emu -b -e %ROM%"
    addEmulator 1 "$md_id" "wii" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 0 "$md_id-gui" "wii" "$md_inst/bin/dolphin-emu -b -e %ROM%"

    addSystem "gc"
    addSystem "wii"
}
