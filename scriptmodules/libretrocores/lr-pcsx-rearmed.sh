#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-pcsx-rearmed"
rp_module_desc="Playstation emulator - PCSX (arm optimised) port for libretro"
rp_module_menus="2+"

function depends_lr-pcsx-rearmed() {
    getDepends libpng12-dev libx11-dev
}

function sources_lr-pcsx-rearmed() {
    gitPullOrClone "$md_build" git://github.com/libretro/pcsx_rearmed.git
}

function build_lr-pcsx-rearmed() {
    ./configure --platform=libretro
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_lr-pcsx-rearmed() {
    md_ret_files=(
        'AUTHORS'
        'ChangeLog.df'
        'COPYING'
        'libretro.so'
        'NEWS'
        'README.md'
        'readme.txt'
    )
}

function configure_lr-pcsx-rearmed() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/psxlibretro"

    mkRomDir "psx"
    ensureSystemretroconfig "psx"

    # system-specific, PSX
    iniConfig " = " "" "$configdir/psx/retroarch.cfg"
    iniSet "rewind_enable" "false"

    addSystem 1 "$md_id" "psx" "$md_inst/libretro.so"
}
