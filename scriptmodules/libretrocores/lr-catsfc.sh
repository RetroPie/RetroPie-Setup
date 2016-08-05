#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-catsfc"
rp_module_desc="SNES emu - CATSFC based on Snes9x / NDSSFC / BAGSFC"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_section="main"

function sources_lr-catsfc() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x2005.git
}

function build_lr-catsfc() {
    make clean
    make
    md_ret_require="$md_build/snes9x2005_libretro.so"
}

function install_lr-catsfc() {
    md_ret_files=(
        'snes9x2005_libretro.so'
    )
}

function configure_lr-catsfc() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addSystem 0 "$md_id" "snes" "$md_inst/snes9x2005_libretro.so"
}
