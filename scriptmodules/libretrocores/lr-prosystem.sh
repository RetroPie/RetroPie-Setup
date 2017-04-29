#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
#  Many, many thanks go to all people that provide the individual modules!!!
#

rp_module_id="lr-prosystem"
rp_module_desc="Atari 7800 ProSystem emu - ProSystem port for libretro"
rp_module_help="ROM Extensions: .a78 .bin .zip\n\nCopy your Atari 7800 roms to $romdir/atari7800\n\nCopy the optional BIOS file 7800 BIOS (U).rom to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/prosystem-libretro/master/License.txt"
rp_module_section="main"

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
        'README.md'
    )
}

function configure_lr-prosystem() {
    mkRomDir "atari7800"

    ensureSystemretroconfig "atari7800"

    addEmulator 1 "$md_id" "atari7800" "$md_inst/prosystem_libretro.so"
    addSystem "atari7800"
}
