#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gl4es"
rp_module_desc="GL4ES - OpenGL 2.1/1.5 to GL ES 2.0/1.1 translation library"
rp_module_licence="OTHER https://github.com/ptitSeb/gl4es/blob/master/LICENSE"
rp_module_section=""
rp_module_flags=""

function depends_gl4es() {
    local depends=(libgl1-mesa-dev libgles2-mesa-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)

    getDepends "${depends[@]}"
}

function sources_gl4es() {
    gitPullOrClone "$md_build" https://github.com/ptitSeb/gl4es
}

function build_gl4es() {
    local params=()
    isPlatform "videocore" && params=("-DBCMHOST=1")

    rm -rf build
    mkdir build
    cd build
    cmake .. "${params[@]}"
    make

    md_ret_require="$md_build/build/lib/libGL.so.1"
}

function install_gl4es() {
    md_ret_files=(
        'build/lib/libGL.so.1'
        'README.md'
        'LICENSE'
    )
}
