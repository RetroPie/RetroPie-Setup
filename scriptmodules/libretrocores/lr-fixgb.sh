#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fixgb"
rp_module_desc="Gameboy (Color) emu - fixGB port for libretro"
rp_module_help="ROM Extensions: .gb .gbc .gbs .zip .7z\n\nCopy your GameBoy roms to $romdir/gb\nCopy your GameBoy Color roms to $romdir/gbc\n\nCopy gbc_bios.bin (Game Boy Color BIOS) to $biosdir"
rp_module_licence="MIT https://raw.githubusercontent.com/FIX94/fixGB/master/LICENSE"
rp_module_section="exp x86=opt"
rp_module_flags=""

function sources_lr-fixgb() {
    gitPullOrClone "$md_build" https://github.com/FIX94/fixGB.git
}

function build_lr-fixgb() {
    cd libretro
    make clean
    make -j`nproc`
    md_ret_require="$md_build/libretro/fixgb_libretro.so"
}

function install_lr-fixgb() {
    md_ret_files=(
	'LICENSE'
	'README.md'
	'libretro/fixgb_libretro.so'
    )
}

function configure_lr-fixgb() {
    for x in gb gbc; do
        mkRomDir "$x"
        ensureSystemretroconfig "$x"

        addEmulator 1 "$md_id" "$x" "$md_inst/fixgb_libretro.so"
        addSystem "$x"
    done
}
