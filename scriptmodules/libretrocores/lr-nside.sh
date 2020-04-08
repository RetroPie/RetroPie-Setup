#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-nside"
rp_module_desc="Super Nintendo emu - nSide (Higan balanced v1.06) port for libretro"
rp_module_help="ROM Extensions: .sfc .smc .rom .bml .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/nSide/master/gpl-3.0.txt"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-nside() {
    gitPullOrClone "$md_build" https://github.com/libretro/nSide.git
}

function build_lr-nside() {
    cd "nSide"
    make clean
    make target=libretro binary=library -j`nproc`
    md_ret_require="$md_build/nSide/out/higan_sfc_balanced_libretro.so"
}

function install_lr-nside() {
    md_ret_files=(
        'gpl-3.0.txt'
        'nSide/out/higan_sfc_balanced_libretro.so'
    )
}

function configure_lr-nside() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/higan_sfc_balanced_libretro.so"
    addSystem "snes"
}
