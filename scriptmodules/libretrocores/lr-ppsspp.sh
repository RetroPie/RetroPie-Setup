#!/bin/bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-ppsspp"
rp_module_desc="PlayStation Portable emu - PPSSPP port for libretro"
rp_module_menus="2+"
rp_module_flags="!rpi1"

function depends_lr-ppsspp() {
    getDepends libraspberrypi-dev
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_lr-ppsspp() {
    gitPullOrClone "$md_build" https://github.com/joolswills/ppsspp.git libretro_rpi_fix
    git submodule update --init
    # remove the lines that trigger the ffmpeg build script functions - we will just use the variables from it
    sed -i "/^build_ARMv6$/,$ d" ffmpeg/linux_arm.sh
}

function build_lr-ppsspp() {
    # build ffmpeg
    cd ffmpeg
    build_ffmpeg_ppsspp
    cd "$md_build"
    
    make -C libretro clean
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        make -C libretro platform=rpi2 CC=gcc-4.8 CXX=g++-4.8
    else
        make -C libretro platform=rpi2
    fi
    md_ret_require="$md_build/libretro/ppsspp_libretro.so"
}

function install_lr-ppsspp() {
    md_ret_files=(
        'libretro/ppsspp_libretro.so'
        'assets'
        'flash0'
    )
}

function configure_lr-ppsspp() {
    mkRomDir "psp"
    ensureSystemretroconfig "psp"

    mkUserDir "$biosdir/PPSSPP"
    cp -Rv "$md_inst/assets/"* "$biosdir/PPSSPP/"
    cp -Rv "$md_inst/flash0" "$biosdir/PPSSPP/"
    chown -R $user:$user "$biosdir/PPSSPP"

    addSystem 1 "$md_id" "psp" "$md_inst/ppsspp_libretro.so"
}
