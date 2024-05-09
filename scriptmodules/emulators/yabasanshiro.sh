#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="yabasanshiro"
rp_module_desc="SEGA Saturn emulator Yaba Sanshiro"
rp_module_help="ROM Extensions: .cue .chd\n\nCopy your SEGA Saturn ios images to $romdir/saturn"
rp_module_licence="GPL2 https://github.com/devmiyax/yabause/blob/master/LICENSE"
rp_module_repo="git https://github.com/devmiyax/yabause.git pi4-1-9-0"
rp_module_section="exp"
rp_module_flags="!all rpi !videocore"

function depends_yabasanshiro() {
    local depends=(cmake pkg-config protobuf-compiler libprotobuf-dev libsecret-1-dev libssl-dev libsdl2-dev libboost-all-dev)
    getDepends "${depends[@]}"
}

function sources_yabasanshiro() {
    gitPullOrClone
}

function build_yabasanshiro() {
    local params=(-DGIT_EXECUTABLE=/usr/bin/git -DUSE_EGL=ON -DYAB_PORTS=retro_arena -DYAB_WANT_DYNAREC_DEVMIYAX=ON -DYAB_WANT_ARM7=ON -DYAB_WANT_OPENAL=OFF -DCMAKE_INSTALL_PREFIX="$md_inst")
    isPlatform "32bit" && params+=(-DCMAKE_SYSTEM_PROCESSOR=armv7-a)
    isPlatform "64bit" && params+=(-DCMAKE_SYSTEM_PROCESSOR=aarch64)

    export CFLAGS="$CFLAGS -D_POSIX_C_SOURCE=199309L -D__PI4__ -D__RETORO_ARENA__"
    export CXXFLAGS="$CXXFLAGS -D__PI4__ -D__RETORO_ARENA_"

    rm -fr build && mkdir -p build
    cd build
    cmake ../yabause/ "${params[@]}"
    make
    md_ret_require="$md_build/build/src/retro_arena/yabasanshiro"
}

function install_yabasanshiro() {
    cd build
    make install
}


function configure_yabasanshiro() {
    mkRomDir "saturn"
    if [[ "$md_mode" == "install" ]]; then
       mkUserDir "$md_conf_root/saturn"
       mkUserDir "$md_conf_root/saturn/$md_id"
       moveConfigFile "$home/.$md_id" "$md_conf_root/saturn/$md_id"
    fi
    addEmulator 1 "$md_id" "saturn" "$md_inst/yabasanshiro -r 3 -i %ROM%"
    addSystem "saturn"
}
