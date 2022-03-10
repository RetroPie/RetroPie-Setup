#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-cdi2015"
rp_module_desc="CDi - MAME 0.160 port for libretro build for CDi"
rp_module_help="ROM Extension: .chd\n\nCopy your CDi images to $romdir/cdi"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2015-libretro/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/mame2015-libretro.git master"
rp_module_section="exp"

function sources_lr-cdi2015() {
    gitPullOrClone
}

function build_lr-cdi2015() {
    rpSwap on 1200
    make clean
    make SUBTARGET=cdi 
    rpSwap off
    md_ret_require="$md_build/cdi2015_libretro.so"
}

function install_lr-cdi2015() {
    md_ret_files=(
        'cdi2015_libretro.so'
        'docs/README-original.md'
        'docs/license.txt'
    )
}

function configure_lr-cdi2015() {
    mkRomDir "cdi"
    ensureSystemretroconfig "cdi"

    addEmulator 1 "$md_id" "cdi" "$md_inst/cdi2015_libretro.so"
    addSystem "cdi"
}
