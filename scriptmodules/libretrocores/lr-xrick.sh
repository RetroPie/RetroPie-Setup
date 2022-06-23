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
rp_module_desc="Open source implementation of Rick Dangerous - xrick ported for libretro"
rp_module_help="Install the xrick data.zip to $romdir/ports/xrick/data.zip"
rp_module_licence="GPL https://raw.githubusercontent.com/libretro/xrick-libretro/master/README"
rp_module_repo="git https://github.com/libretro/xrick-libretro.git master"
rp_module_section="opt"

function sources_lr-xrick() {
    gitPullOrClone
}

function build_lr-xrick() {
    make clean
    make
    md_ret_require="$md_build/xrick_libretro.so"
}

function install_lr-xrick() {
    md_ret_files=(
        'README'
        'README.md'
        'xrick_libretro.so'
    )
}

function configure_lr-xrick() {
    setConfigRoot "ports"

    addPort "$md_id" "xrick" "XRick" "$md_inst/xrick_libretro.so" "$romdir/ports/xrick/data.zip"

    [[ "$md_mode" == "remove" ]] && return

    defaultRAConfig "xrick"
}
