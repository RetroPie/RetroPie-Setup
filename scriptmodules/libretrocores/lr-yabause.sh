#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-yabause"
rp_module_desc="Sega Saturn emu - Yabause (optimised) port for libretro"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_lr-yabause() {
    gitPullOrClone "$md_build" https://github.com/libretro/yabause.git
}

function build_lr-yabause() {
    cd libretro
    make clean
    make platform=armvneonhardfloat
    md_ret_require="$md_build/libretro/yabause_libretro.so"
}

function install_lr-yabause() {
    md_ret_files=(
        'libretro/yabause_libretro.so'
        'yabause/AUTHORS'
        'yabause/COPYING'
        'yabause/ChangeLog'
        'yabause/AUTHORS'
        'yabause/GOALS'
        'yabause/README'
        'yabause/README.LIN'
    )
}

function configure_lr-yabause() {
    mkRomDir "saturn"
    ensureSystemretroconfig "saturn"
    
    addSystem 1 "$md_id" "saturn" "$md_inst/yabause_libretro.so"
}
