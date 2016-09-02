#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-pocketsnes"
rp_module_desc="SNES emu - ARM based SNES emulator for libretro"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_section="main"
rp_module_flags="!x86"

function sources_lr-pocketsnes() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x2002.git
}

function build_lr-pocketsnes() {
    make clean
    CFLAGS="$CFLAGS" make ARM_ASM=1
    md_ret_require="$md_build/snes9x2002_libretro.so"
}

function install_lr-pocketsnes() {
    md_ret_files=(
        'snes9x2002_libretro.so'
        'README.txt'
    )
}

function configure_lr-pocketsnes() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    local def=0
    isPlatform "armv6" && def=1
    addSystem $def "$md_id" "snes" "$md_inst/snes9x2002_libretro.so"
}
