#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-frodo"
rp_module_desc="Commodore 64 emulator - Frodo port for libretro"
rp_module_help="ROM Extensions: .d64 .t64 .x64 .p00 .lnx .zip .7z\n\nCopy your ROMs file to $romdir/c64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/frodo/master/COPYING"
rp_module_section="exp"

function sources_lr-frodo() {
    gitPullOrClone "$md_build" https://github.com/libretro/frodo-libretro.git
    applyPatch "$md_data/0001-fix-compile-with-gcc6.patch" 
    applyPatch "$md_data/0002-autoload.patch"
}

function build_lr-frodo() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/frodo_libretro.so"
}

function install_lr-frodo() {
    md_ret_files=(
	'frodo_libretro.so'
	'COPYING'
    )
}

function configure_lr-frodo() {
    mkRomDir "c64"
    ensureSystemretroconfig "c64"

    addEmulator 1 "$md_id" "c64" "$md_inst/frodo_libretro.so"
    addSystem "c64"
}
