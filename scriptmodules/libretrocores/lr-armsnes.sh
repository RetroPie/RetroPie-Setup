#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-armsnes"
rp_module_desc="SNES emu - forked from pocketsnes focused on performance"
rp_module_menus="2+"

function sources_lr-armsnes() {
    gitPullOrClone "$md_build" git://github.com/rmaz/ARMSNES-libretro
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch src/ppu.cpp
}

function build_lr-armsnes() {
    make clean
    make
    md_ret_require="$md_build/libpocketsnes.so"
}

function install_lr-armsnes() {
    md_ret_files=(
        'libpocketsnes.so'
    )
}

function configure_lr-armsnes() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/armsnes"

    mkRomDir "snes"
    ensureSystemretroconfig "snes" "snes_phosphor.glslp"

    addSystem 0 "$md_id" "snes" "$md_inst/libpocketsnes.so"
}
