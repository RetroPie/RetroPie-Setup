#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-nestopia"
rp_module_desc="NES emu - Nestopia (enhanced) port for libretro"
rp_module_menus="2+"

function sources_lr-nestopia() {
    gitPullOrClone "$md_build" https://github.com/libretro/nestopia.git
}

function build_lr-nestopia() {
    cd libretro
    # remove unneeded gtk3 stuff from Makefile,
    # this speeds up compilation, uses less RAM and no need to enable swap. 
    # compiles using all 4 cores on the RPi2, using less than 500MB of RAM.
    make clean
    make
    md_ret_require="$md_build/libretro/nestopia_libretro.so"
}

function install_lr-nestopia() {
    md_ret_files=(
        'libretro/nestopia_libretro.so'
        'NstDatabase.xml'
        'README.md'
        'README.unix'
        'changelog.txt'
        'readme.html'
        'COPYING'
        'AUTHORS'
    )
}

function configure_lr-nestopia() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/nestopia"

    mkRomDir "nes"
    mkRomDir "fds"
    ensureSystemretroconfig "nes" "phosphor.glslp"
    ensureSystemretroconfig "fds" "phosphor.glslp"

    delSystem "$md_id" "nes-nestopia"
    addSystem 0 "$md_id" "nes" "$md_inst/nestopia_libretro.so"
    addSystem 1 "$md_id" "fds" "$md_inst/nestopia_libretro.so"
}
