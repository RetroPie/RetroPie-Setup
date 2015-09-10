#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fba-next"
rp_module_desc="Arcade emu - Final Burn Alpha (0.2.97.36) port for libretro"
rp_module_menus="4+"

function depends_lr-fba-next() {
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_lr-fba-next() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-fba.git
}

function build_lr-fba-next() {
    make -f makefile.libretro clean
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        make -f makefile.libretro CC="gcc-4.8" CXX="g++-4.8" platform=armv profile=performance
    else
        make -f makefile.libretro platform=armv profile=performance
    fi
    md_ret_require="$md_build/fba_libretro.so"
}

function install_lr-fba-next() {
    md_ret_files=(
        'fba.chm'
        'fba_libretro.so'
        'gamelist.txt'
        'whatsnew.html'
        'preset-example.zip'
    )
}

function configure_lr-fba-next() {
    mkRomDir "fba"
    ensureSystemretroconfig "fba"

    addSystem 1 "$md_id" "neogeo" "$md_inst/fba_libretro.so"
    addSystem 1 "$md_id" "fba arcade" "$md_inst/fba_libretro.so"
}
