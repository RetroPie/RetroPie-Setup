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
rp_module_menus="4+"

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

    cp "$md_inst/system/bluemsx/Machines/Shared Roms"{*.ROM,*.rom} "$biosdir/system/bluemsx/Machines/Shared Roms"
    chown $user:$user "$biosdir/system/bluemsx/Machines/Shared Roms"{*.ROM,*.rom}

    # default to MSX2+ core
    iniConfig " = " "" "$configdir/all/retroarch-core-options.cfg"
    iniSet "bluemsx_msxtype" "MSX2+"
    chown $user:$user "$configdir/all/retroarch-core-options.cfg"

    addSystem 1 "$md_id" "msx" "$md_inst/bluemsx_libretro.so"
}