#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pcsx2"
rp_module_desc="PS2 emulator PCSX2"
rp_module_help="ROM Extensions: .bin .iso .img .mdf .z .z2 .bz2 .cso .ima .gz\n\nCopy your PS2 roms to $romdir/ps2\n\nCopy the required BIOS file to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_pcsx2() {
    # Build dependencies (from the Debian/Ubuntu package: https://github.com/PCSX2/pcsx2/blob/master/debian-packager/control)
    local depends=(cmake libaio-dev:i386 libasound2-dev:i386 libbz2-dev:i386 libgl1-mesa-dev:i386 libglu1-mesa-dev:i386 libgtk2.0-dev:i386 liblzma-dev:i386 libpng-dev:i386 libpulse-dev:i386 libpcap0.8-dev:i386 libsdl2-dev:i386 libsoundtouch-dev:i386 libwxbase3.0-dev:i386 libwxgtk3.0-dev:i386 libx11-dev:i386 libxml2-dev:i386 portaudio19-dev:i386 zlib1g-dev:i386 libasound2-plugins:i386 libusb-0.1-4:i386)
    if isPlatform "64bit"; then
        # We need to add the target architecture (no side effects if it's already added)
        dpkg --add-architecture i386
        # Installing compiler dependencies for crossbuild
        depends+=(gcc-multilib g++-multilib)
    fi
    getDepends "${depends[@]}"
}

function sources_pcsx2() {
    gitPullOrClone "$md_build" https://github.com/PCSX2/pcsx2.git master
}

function build_pcsx2() {
    mkdir build
    cd build
    # Flags are the same as the Debian/Ubuntu package: https://github.com/PCSX2/pcsx2/blob/master/debian-packager/rules.
    # More info at https://github.com/PCSX2/pcsx2/wiki/Installing-on-Linux.
    # -DCMAKE_BUILD_TYPE=Release  -> Best in speed, but provides little or no debug/crash info 
    # -DXDG_STD=TRUE              -> Use the Debian/Ubuntu configuration dir path, at ~/.config/PCSX2 
    # -DPACKAGE_MODE=TRUE         -> Required to make it installable in different folders
    # -DCMAKE_BUILD_STRIP=FALSE   -> Keep symbols. Better for debug. (recommended since it should not have any impact on speed)
    # -DDISABLE_ADVANCE_SIMD=TRUE -> Disable AVX
    # -DGSDX_LEGACY=TRUE          -> Build a GSdx legacy plugin compatible with GL3.3
    cmake .. -DCMAKE_BUILD_TYPE=Release -DXDG_STD=TRUE -DPACKAGE_MODE=TRUE -DCMAKE_BUILD_STRIP=FALSE -DDISABLE_ADVANCE_SIMD=TRUE -DGSDX_LEGACY=TRUE -DCMAKE_TOOLCHAIN_FILE=cmake/linux-compiler-i386-multilib.cmake -DCMAKE_INSTALL_PREFIX="$md_inst"
    make clean
    make
    md_ret_require="$md_build/build/pcsx2/PCSX2"
}

function install_pcsx2() {
    cd build
    make install
}

function configure_pcsx2() {
    mkRomDir "ps2"
    # Windowed option
    addEmulator 0 "$md_id" "ps2" "$md_inst/bin/PCSX2 %ROM% --windowed"
    # Fullscreen option with no gui (default, because we can close with `Esc` key, easy to map for gamepads)
    addEmulator 1 "$md_id-nogui" "ps2" "$md_inst/bin/PCSX2 %ROM% --fullscreen --nogui"
    addSystem "ps2"
}
