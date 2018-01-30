#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-xrick"
rp_module_desc="xrick - standalone libretro puzzle game"
rp_module_help="xrick game assets are automatically installed to $romdir/ports/xrick/"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/xrick/master/LICENSE"
rp_module_section="exp"

function sources_lr-xrick() {
    gitPullOrClone "$md_build" https://github.com/libretro/xrick-libretro
}

function build_lr-xrick() {
    make clean
    # libretro-common has an issue with neon
    if isPlatform "neon"; then
        CFLAGS="" make
    else
        make
    fi
    md_ret_require="$md_build/xrick_libretro.so"
}

function install_lr-xrick() {
    md_ret_files=(
        'xrick_libretro.so'
        'data.zip'
    )
}


function configure_lr-xrick() {
    setConfigRoot "ports"

    addPort "$md_id" "xrick" "xrick" "$md_inst/xrick_libretro.so" "$romdir/ports/xrick/data.zip"

    mkRomDir "ports/xrick"
    ensureSystemretroconfig "ports/xrick"

    cp -Rv "$md_inst/xrick" "$romdir/ports"

    chown $user:$user -R "$romdir/ports/xrick"
}
