#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-gba"
rp_module_desc="GBA emu - Mednafen VBA-M port for libretro."
rp_module_help="ROM Extensions: .gba .agb .bin .zip .7z\n\nCopy your Game Boy Advance roms to $romdir/gba\n\nCopy the BIOS file gba_bios.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-gba-libretro/master/COPYING"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-beetle-gba() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-gba-libretro.git
}

function build_lr-beetle-gba() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/mednafen_gba_libretro.so"
}

function install_lr-beetle-gba() {
    md_ret_files=(
	'COPYING'
	'mednafen_gba_libretro.so'
    )
}

function configure_lr-beetle-gba() {
    mkRomDir "gba"
    ensureSystemretroconfig "gba"
    addEmulator 1 "$md_id" "gba" "$md_inst/mednafen_gba_libretro.so"
    addSystem "gba"
}
