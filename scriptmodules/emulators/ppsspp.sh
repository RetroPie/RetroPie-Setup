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
rp_module_flags="!armv6 !mali"

function depends_ppsspp() {
    local depends=(cmake libsdl2-dev libzip-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_ppsspp() {
    gitPullOrClone "$md_build" https://github.com/hrydgard/ppsspp.git
    runCmd git submodule update --init --recursive
    # remove the lines that trigger the ffmpeg build script functions - we will just use the variables from it
    sed -i "/^build_ARMv6$/,$ d" ffmpeg/linux_arm.sh

    mkdir cmake
    wget -q -O- "$__archive_url/cmake-3.6.2.tar.gz" | tar -xvz --strip-components=1 -C cmake
}

function build_ffmpeg_ppsspp() {
    if isPlatform "arm"; then
        local MODULES
        local VIDEO_DECODERS
        local AUDIO_DECODERS
        local VIDEO_ENCODERS
        local AUDIO_ENCODERS
        local DEMUXERS
        local MUXERS
        local PARSERS
        local OPTS
        # get the ffmpeg configure variables from the ppsspp ffmpeg distributed script
        source linux_arm.sh
        ./configure \
            ${OPTS} \
            --cpu="cortex-a7" \
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

function build_ppsspp() {
    cd cmake
    ./bootstrap
    make
    cd ..

    # build ffmpeg
    cd ffmpeg
    build_ffmpeg_ppsspp
    cd "$md_build"

    # build ppsspp
    rm -f CMakeCache.txt
    if isPlatform "rpi" && [[ "$__os_id" == "Raspbian" ]]; then
        cmake/bin/cmake -DRASPBIAN=ON .
    else
        cmake/bin/cmake .
    fi
    make clean
    make

    md_ret_require="$md_build/PPSSPPSDL"
}

function install_ppsspp() {
    md_ret_files=(
        'assets'
        'flash0'
        'PPSSPPSDL'
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
