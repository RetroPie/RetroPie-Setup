#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-gambatte"
rp_module_desc="Gameboy Color emu - libgambatte port for libretro"
rp_module_menus="2+"

function sources_lr-gambatte() {
    gitPullOrClone "$md_build" git://github.com/libretro/gambatte-libretro.git
}

function build_lr-gambatte() {
    make -C libgambatte -f Makefile.libretro clean
    make -C libgambatte -f Makefile.libretro
    md_ret_require="$md_build/libgambatte/gambatte_libretro.so"
}

function install_lr-gambatte() {
    md_ret_files=(
        'COPYING'
        'changelog'
        'README'
        'libgambatte/gambatte_libretro.so'
    )
}

function configure_lr-gambatte() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/gbclibretro"

    mkRomDir "gbc"
    mkRomDir "gb"
    ensureSystemretroconfig "gb" "hq4x.glslp"
    ensureSystemretroconfig "gbc" "hq4x.glslp"

    addSystem 1 "$md_id" "gb" "$md_inst/gambatte_libretro.so"
    addSystem 1 "$md_id" "gbc" "$md_inst/gambatte_libretro.so"
}
