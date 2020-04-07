#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-nekop2"
rp_module_desc="PC98 emu - Neko Project II port for libretro"
rp_module_help="ROM Extensions: .d88 .d98 .88d .98d .fdi .xdf .hdm .dup .2hd .tfd .hdi .thd .nhd .hdd\n\nCopy your pc98 games to to $romdir/pc98"
rp_module_license="MIT https://raw.githubusercontent.com/libretro/libretro-meowPC98/master/LICENSE"
rp_module_section="exp"

function sources_lr-nekop2() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-meowPC98.git
}

function build_lr-nekop2() {
    cd "libretro"
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/libretro/nekop2_libretro.so"
}

function install_lr-nekop2() {
    md_ret_files=(
	'libretro/nekop2_libretro.so'
	'LICENSE'
    )
}

function configure_lr-nekop2() {
    mkRomDir "pc98"
    ensureSystemretroconfig "pc98"

    addEmulator 1 "$md_id" "pc98" "$md_inst/nekop2_libretro.so"
    addSystem "pc98"
}
