#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-glupen64"
rp_module_desc="N64 emu - GLupeN64 for libretro"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_section="main"
rp_module_flags="!mali"

function depends_lr-glupen64() {
    getDepends flex bison
}

function sources_lr-glupen64() {
    gitPullOrClone "$md_build" https://github.com/loganmc10/GLupeN64.git
    if isPlatform "armv6"; then
        sed -i "s/-mstackrealign -DARCH_MIN_SSE2 -msse -msse2//" Makefile
    fi
}

function build_lr-glupen64() {
    rpSwap on 750
    make clean
    if isPlatform "rpi"; then
        make platform="$__platform"
    else
        make
    fi
    rpSwap off
    md_ret_require="$md_build/glupen64_libretro.so"
}

function install_lr-glupen64() {
    md_ret_files=(
        'glupen64_libretro.so'
        'README.md'
        'BUILDING.md'
    )
}

function configure_lr-glupen64() {
    mkRomDir "n64"
    ensureSystemretroconfig "n64"

    addSystem 0 "$md_id" "n64" "$md_inst/glupen64_libretro.so"
}
