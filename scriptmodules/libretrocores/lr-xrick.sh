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
rp_module_desc="Rick Dangerous engine - XRick port for libretro"
rp_module_help="ROM Extensions: .zip\n\nData.zip is automatically installed in $romdir/ports/xrick"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/xrick-libretro/master/README"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-xrick() {
    depends_xrick
}

function sources_lr-xrick() {
    gitPullOrClone "$md_build" https://github.com/libretro/xrick-libretro.git
}

function build_lr-xrick() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/xrick_libretro.so"
}

function install_lr-xrick() {
    md_ret_files=(
        'xrick_libretro.so'
	'data.zip'
 	'README'
    )
}

function configure_lr-xrick() {
    setConfigRoot "ports"

    addPort "$md_id" "xrick" "XRick" "$md_inst/xrick_libretro.so" "$romdir/ports/xrick/data.zip"

    mkRomDir "ports/xrick"
    ensureSystemretroconfig "ports/xrick"

    cp -Rv "$md_inst/data.zip" "$romdir/ports/xrick"

    chown $user:$user -R "$romdir/ports/xrick"
}
