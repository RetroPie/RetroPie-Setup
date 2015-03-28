#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-vecx"
rp_module_desc="Vectrex emulator - vecx port for libretro"
rp_module_menus="2+"

function sources_lr-vecx() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-vecx
}

function build_lr-vecx() {
    make clean
    make -f Makefile.libretro
    md_ret_require="$md_build/vecx_libretro.so"
}

function install_lr-vecx() {
    md_ret_files=(
        'vecx_libretro.so'
        'bios/fast.bin'
        'bios/skip.bin'
        'bios/system.bin'
    )
}

function configure_lr-vecx() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/libretro-vecx"

    mkRomDir "vectrex"
    ensureSystemretroconfig "vectrex"

    # Copy bios files
    cp -v "$md_inst/"{fast.bin,skip.bin,system.bin} "$biosdir/"
    chown $user:$user "$biosdir/"{fast.bin,skip.bin,system.bin}

    addSystem 1 "$md_id" "vectrex" "$md_inst/vecx_libretro.so"
}
