#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-catsfc"
rp_module_desc="SNES emu - CATSFC based on Snes9x / NDSSFC / BAGSFC"
rp_module_menus="2+"

function sources_lr-catsfc() {
    gitPullOrClone "$md_build" git://github.com/libretro/CATSFC-libretro.git
}

function build_lr-catsfc() {
    make clean
    make
    md_ret_require="$md_build/catsfc_libretro.so"
}

function install_lr-catsfc() {
    md_ret_files=(
        'catsfc_libretro.so'
    )
}

function configure_lr-catsfc() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/catsfc"

    mkRomDir "snes"
    ensureSystemretroconfig "snes" "snes_phosphor.glslp"

    delSystem "$md_id" "snes-catsfc"
    addSystem 0 "$md_id" "snes" "$md_inst/catsfc_libretro.so"
}
