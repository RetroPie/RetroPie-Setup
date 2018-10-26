#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fbalpha2018"
rp_module_desc="Arcade emu - Final Burn Alpha (v0.2.97.43) port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA roms."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fbalpha2018/master/src/license.txt"
rp_module_section="main"

function sources_lr-fbalpha2018() {
    gitPullOrClone "$md_build" https://github.com/libretro/fbalpha2018.git
}

function build_lr-fbalpha2018() {
    build_lr-fbalpha
}

function install_lr-fbalpha2018() {
    install_lr-fbalpha
}

function configure_lr-fbalpha2018() {
    configure_lr-fbalpha
}
