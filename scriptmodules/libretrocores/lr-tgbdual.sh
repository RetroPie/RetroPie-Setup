#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-tgbdual"
rp_module_desc="Gameboy Color emu - TGB Dual port for libretro"
rp_module_menus="2+"

function sources_lr-tgbdual() {
    gitPullOrClone "$md_build" https://github.com/libretro/tgbdual-libretro.git
}

function build_lr-tgbdual() {
    make clean
    make
    md_ret_require="$md_build/tgbdual_libretro.so"
}

function install_lr-tgbdual() {
    md_ret_files=(
        'tgbdual_libretro.so'
    )
}

function configure_lr-tgbdual() {
    mkRomDir "gbc"
    mkRomDir "gb"
    ensureSystemretroconfig "gb" "hq4x.glslp"
    ensureSystemretroconfig "gbc" "hq4x.glslp"

    # enable dual / link by default
    setRetroArchCoreOption "tgbdual_gblink_enable" "enabled"

    addSystem 0 "$md_id" "gb" "$md_inst/tgbdual_libretro.so"
    addSystem 0 "$md_id" "gbc" "$md_inst/tgbdual_libretro.so"
}
