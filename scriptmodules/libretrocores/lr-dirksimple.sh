#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dirksimple"
rp_module_desc="laserdisc emu - DirkSimple"
rp_module_help="ROM Extensions: .ogv .dirksimple\n\nCopy your laserdisc movies in Ogg Theora format to $romdir/dirksimple"
rp_module_licence="zlib https://raw.githubusercontent.com/icculus/DirkSimple/main/LICENSE.txt"
rp_module_repo="git https://github.com/icculus/DirkSimple.git main"
rp_module_section="exp"

function depends_lr-dirksimple() {
    local depends=(cmake)
    getDepends "${depends[@]}"
}

function sources_lr-dirksimple() {
    gitPullOrClone
}

function build_lr-dirksimple() {
    local params=(
        '-DDIRKSIMPLE_LIBRETRO=ON'
        '-DDIRKSIMPLE_SDL=OFF'
        '-DCMAKE_BUILD_TYPE=Release'
    )

    isPlatform "neon" && params+=' -DCMAKE_C_FLAGS="-mfpu=neon"'

    rm -fr build && mkdir build
    cd build
    echo "cmake" "${params[@]}" ..
    cmake "${params[@]}" ..
    make dirksimple_libretro
    md_ret_require="$md_build/build/dirksimple_libretro.so"
}

function install_lr-dirksimple() {
    md_ret_files=(
        'build/dirksimple_libretro.so'
    )

    rm -rf "$biosdir/DirkSimple"
    mkUserDir "$biosdir/DirkSimple"
    cp -rf "$md_build/data" "$biosdir/DirkSimple/"
    chown -R $user:$user "$biosdir/DirkSimple"
}

function configure_lr-dirksimple() {
    mkRomDir "dirksimple"
    defaultRAConfig "dirksimple"

    addEmulator 0 "$md_id" "dirksimple" "$md_inst/dirksimple_libretro.so"
    addSystem "dirksimple"
}

