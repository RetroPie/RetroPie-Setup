#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-blastem"
rp_module_desc="Sega Genesis emu - BlastEm port for libretro"
rp_module_help="ROM Extensions: .md .bin .smd .zip .7z\n\nCopy the required BIOS file rom.db to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/blastem/master/COPYING"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function sources_lr-blastem() {
    gitPullOrClone "$md_build" https://github.com/libretro/blastem.git libretro
}

function build_lr-blastem() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/blastem_libretro.so"
}

function install_lr-blastem() {
    md_ret_files=(
        'README'
        'blastem_libretro.so'
    )
}

function configure_lr-blastem() {
    mkRomDir "megadrive"
    ensureSystemretroconfig "megadrive"
    addEmulator 1 "$md_id" "megadrive" "$md_inst/blastem_libretro.so"
    addSystem "megadrive"
}
