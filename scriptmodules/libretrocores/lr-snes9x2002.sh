#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-snes9x2002"
rp_module_desc="Super Nintendo emu - ARM optimised Snes9x 1.39 port for libretro"
rp_module_help="Previously called lr-pocketsnes\n\nROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x2002/master/src/copyright.h"
rp_module_section="main"
rp_module_flags="!x86 !aarch64"

function _update_hook_lr-snes9x2002() {
    # move from old location and update emulators.cfg
    renameModule "lr-pocketsnes" "lr-snes9x2002"
}

function sources_lr-snes9x2002() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x2002.git
}

function build_lr-snes9x2002() {
    make clean
    CFLAGS="$CFLAGS -Wa,-mimplicit-it=thumb" make ARM_ASM=1
    md_ret_require="$md_build/snes9x2002_libretro.so"
}

function install_lr-snes9x2002() {
    md_ret_files=(
        'snes9x2002_libretro.so'
        'README.txt'
    )
}

function configure_lr-snes9x2002() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    local def=0
    isPlatform "armv6" && def=1
    addEmulator $def "$md_id" "snes" "$md_inst/snes9x2002_libretro.so"
    addSystem "snes"
}
