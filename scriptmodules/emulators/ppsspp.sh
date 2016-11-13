#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ppsspp"
rp_module_desc="PlayStation Portable emulator PPSSPP"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_ppsspp() {
    local depends=(cmake libsdl2-dev libzip-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_ppsspp() {
    gitPullOrClone "$md_build/ppsspp" https://github.com/hrydgard/ppsspp.git
    cd ppsspp
    runCmd git submodule update --init --recursive
    # remove the lines that trigger the ffmpeg build script functions - we will just use the variables from it
    sed -i "/^build_ARMv6$/,$ d" ffmpeg/linux_arm.sh

    cd ..
    mkdir -p cmake
    wget -q -O- "$__archive_url/cmake-3.6.2.tar.gz" | tar -xvz --strip-components=1 -C cmake
}

function build_ffmpeg_ppsspp() {
    cd "$1"
    if isPlatform "arm"; then
        local MODULES
        local VIDEO_DECODERS
        local AUDIO_DECODERS
        local VIDEO_ENCODERS
        local AUDIO_ENCODERS
        local DEMUXERS
        local MUXERS
        local PARSERS
        local GENERAL
        local OPTS # used by older lr-ppsspp fork
        # get the ffmpeg configure variables from the ppsspp ffmpeg distributed script
        source linux_arm.sh
        # linux_arm.sh has set -e which we need to switch off
        set +e
        ./configure \
            --prefix="./linux/arm" \
            --extra-cflags="-fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300" \
            --disable-shared \
            --enable-static \
            --enable-zlib \
            --enable-pic \
            --disable-everything \
            ${MODULES} \
            ${VIDEO_DECODERS} \
            ${AUDIO_DECODERS} \
            ${VIDEO_ENCODERS} \
            ${AUDIO_ENCODERS} \
            ${DEMUXERS} \
            ${MUXERS} \
            ${PARSERS}
    fi
    make clean
    make install
}

function build_cmake_ppsspp() {
    cd "$md_build/cmake"
    ./bootstrap
    make
}

function build_ppsspp() {
    build_cmake_ppsspp
    build_ffmpeg_ppsspp "$md_build/ppsspp/ffmpeg"

    # build ppsspp
    local cmake="$md_build/cmake/bin/cmake"
    cd "$md_build/ppsspp"
    rm -rf CMakeCache.txt CMakeFiles
    if isPlatform "rpi"; then
        if isPlatform "armv6"; then
            "$cmake" -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv6.cmake .
        else
            "$cmake" -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv7.cmake .
        fi
    else
        "$cmake" .
    fi
    make clean
    make

    md_ret_require="$md_build/ppsspp/PPSSPPSDL"
}

function install_ppsspp() {
    md_ret_files=(
        'ppsspp/assets'
        'ppsspp/flash0'
        'ppsspp/PPSSPPSDL'
    )
}

function configure_ppsspp() {
    mkRomDir "psp"

    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
    mkUserDir "$md_conf_root/psp/PSP"
    ln -snf "$romdir/psp" "$md_conf_root/psp/PSP/GAME"

    addSystem 0 "$md_id" "psp" "$md_inst/PPSSPPSDL %ROM%"
}
