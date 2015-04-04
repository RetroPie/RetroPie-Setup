#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#
#  Many, many thanks go to all people that provide the individual modules!!!
#

rp_module_id="lr-prosystem"
rp_module_desc="Atari 7800 ProSystem emu - ProSystem port for libretro"
rp_module_menus="2+"

function sources_lr-prosystem() {
    gitPullOrClone "$md_build" https://github.com/libretro/prosystem-libretro.git
}

function build_lr-prosystem() {
    make clean
    CXXFLAGS="$CXXFLAGS -fsigned-char" make
    md_ret_require="$md_build/prosystem_libretro.so"
}

function install_lr-prosystem() {
    md_ret_files=(
        'prosystem_libretro.so'
        'ProSystem.dat'
        'README.md'
    )
}

function configure_lr-prosystem() {
    mkRomDir "atari7800"

    ensureSystemretroconfig "atari7800"

    # symlink ProSystem.dat
    ln -sf "$md_inst/ProSystem.dat" "$biosdir/ProSystem.dat"

    addSystem 1 "$md_id" "atari7800" "$md_inst/prosystem_libretro.so"
}
