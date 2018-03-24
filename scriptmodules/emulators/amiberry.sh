#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="amiberry"
rp_module_desc="Amiga emulator with JIT support (forked from uae4arm)"
rp_module_help="ROM Extension: .adf\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/midwan/amiberry/master/COPYING"
rp_module_section="opt"
rp_module_flags="!x86"

function depends_amiberry() {
    local depends=(libpng12-dev libmpeg2-4-dev zlib1g-dev)
    if ! isPlatform "rpi" || isPlatform "kms"; then
        depends+=(libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev)
    fi

    depends_uae4arm "${depends[@]}"
}

function sources_amiberry() {
    gitPullOrClone "$md_build" https://github.com/midwan/amiberry/
}

function build_amiberry() {
    local amiberry_bin="$__platform-sdl2"
    local amiberry_platform="$__platform-sdl2"
    if isPlatform "rpi" && ! isPlatform "kms"; then
        amiberry_bin="$__platform-sdl1"
        amiberry_platform="$__platform"
    elif isPlatform "odroid-xu"; then
        amiberry_bin="xu4"
        amiberry_platform="xu4"
    elif isPlatform "tinker"; then
        amiberry_bin="tinker"
        amiberry_platform="tinker"
    fi

    make clean
    CXXFLAGS="" make PLATFORM="$amiberry_platform"
    ln -sf "amiberry-$amiberry_bin" "amiberry"
    md_ret_require="$md_build/amiberry-$amiberry_bin"
}

function install_amiberry() {
    local amiberry_bin="$__platform-sdl2"
    if isPlatform "rpi" && ! isPlatform "kms"; then
        amiberry_bin="$__platform-sdl1"
    elif isPlatform "odroid-xu"; then
        amiberry_bin="xu4"
    elif isPlatform "tinker"; then
        amiberry_bin="tinker"
    fi

    md_ret_files=(
        'data'
        "amiberry-$amiberry_bin"
        'amiberry'
    )
}

function configure_amiberry() {
    configure_uae4arm
    moveConfigDir "$md_inst/controllers" "$configdir/all/retroarch/autoconfig"
    moveConfigFile "$md_inst/conf/retroarch.cfg" "$configdir/all/retroarch.cfg"
}
