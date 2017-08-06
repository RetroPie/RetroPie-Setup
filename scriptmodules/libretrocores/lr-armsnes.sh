#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-armsnes"
rp_module_desc="SNES emu - forked from pocketsnes focused on performance"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/RetroPie/ARMSNES-libretro/master/src/snes9x.h"
rp_module_section="opt"
rp_module_flags="!x86 !aarch64"

function sources_lr-armsnes() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/ARMSNES-libretro
}

function build_lr-armsnes() {
    make clean
    CFLAGS="$CFLAGS -Wa,-mimplicit-it=thumb" make
    md_ret_require="$md_build/libpocketsnes.so"
}

function install_lr-armsnes() {
    md_ret_files=(
        'libpocketsnes.so'
    )
}

function configure_lr-armsnes() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/libpocketsnes.so"
    addSystem "snes"
}
