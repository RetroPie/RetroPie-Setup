#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2003"
rp_module_desc="Arcade emu - MAME 0.78 port for libretro"
rp_module_menus="4+"

function sources_lr-mame2003() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2003-libretro.git
    sed -i "s/MD = -mkdir/MD = -mkdir -p" Makefile
}

function build_lr-mame2003() {
    make clean
    make ARCH="$CFLAGS -fsigned-char"
}

function install_lr-mame2003() {
    md_ret_files=(
        'mame078_libretro.so'
        'README'
        'changed.txt'
        'whatsnew.txt'
        'whatsold.txt'
    )
}

function configure_lr-mame2003() {
    mkRomDir "mame-libretro"
    ensureSystemretroconfig "mame"

    addSystem 1 "$md_id" "mame-libretro arcade mame" "$md_inst/mame078_libretro.so"
}
