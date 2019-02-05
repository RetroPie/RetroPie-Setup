#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-freechaf"
rp_module_desc="ChannelF emulator for libretro"
rp_module_help="ROM Extensions: .bin .rom\n\nCopy your ChannelF roms to $romdir/channelf\n\nCopy the required BIOS files sl31245.bin and sl31253.bin or sl90025.bin to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/FreeChaF/master/LICENSE"
rp_module_section="exp"

function sources_lr-freechaf() {
    gitPullOrClone "$md_build" https://github.com/libretro/FreeChaF.git
}

function build_lr-freechaf() {
    make clean
    make
    md_ret_require="$md_build/freechaf_libretro.so"
}

function install_lr-freechaf() {
    md_ret_files=(
        'freechaf_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-freechaf() {
    mkRomDir "channelf"
    ensureSystemretroconfig "channelf"

    addEmulator 1 "$md_id" "channelf" "$md_inst/freechaf_libretro.so"
    addSystem "channelf"
}
