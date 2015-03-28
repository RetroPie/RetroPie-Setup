#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-snes9x-next"
rp_module_desc="SNES emulator - Snes9x 1.52+ (optimised) port for libretro"
rp_module_menus="2+"
rp_module_flags="!rpi1"

function sources_lr-snes9x-next() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x-next
}

function build_lr-snes9x-next() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro platform=armvneon
    md_ret_require="$md_build/snes9x_next_libretro.so"
}

function install_lr-snes9x-next() {
    md_ret_files=(
        'snes9x_next_libretro.so'
        'docs/changes.txt'  
        'docs/control-inputs.txt'  
        'docs/controls.txt'  
        'docs/gpl-2.0.txt'  
        'docs/lgpl-2.1.txt'  
        'docs/porting.html' 
        'docs/snapshots.txt' 
        'docs/snes9x-license.txt'
    )
}

function configure_lr-snes9x-next() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/snes9x-next"

    mkRomDir "snes"
    ensureSystemretroconfig "snes" "snes_phosphor.glslp"

    addSystem 1 "$md_id" "snes" "$md_inst/snes9x_next_libretro.so"
}
