#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bluemsx"
rp_module_desc="MSX/MSX2 emu - blueMSX port for libretro"
rp_module_menus="2+"

function sources_lr-bluemsx() {
    gitPullOrClone "$md_build" https://github.com/HerbFargus/blueMSX-libretro.git
}

function build_lr-bluemsx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/bluemsx_libretro.so"
}

function install_lr-bluemsx() {
    md_ret_files=(
        'bluemsx_libretro.so'
        'README.md'
        'system/bluemsx/Databases'
        'system/bluemsx/Machines'
    )
}

function configure_lr-bluemsx() {
    mkRomDir "msx"
    ensureSystemretroconfig "msx"

    cp -rv "$md_inst/"{Databases,Machines} "$biosdir/"
    chown -R $user:$user "$biosdir/"{Databases,Machines}

    # default to MSX2+ core
    setRetroArchCoreOption "bluemsx_msxtype" "MSX2+"

    addSystem 1 "$md_id" "msx" "$md_inst/bluemsx_libretro.so"
}