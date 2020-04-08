#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes-cplusplus98"
rp_module_desc="Super Nintendo emu - bsnes C++98 (v0.85) port for libretro"
rp_module_help="ROM Extensions: .smc .sfc .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-bsnes-cplusplus98() {
    gitPullOrClone "$md_build" https://github.com/libretro/bsnes-libretro-cplusplus98.git
}

function build_lr-bsnes-cplusplus98() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/out/bsnes_cplusplus98_libretro.so"
}

function install_lr-bsnes-cplusplus98() {
    md_ret_files=(
        'out/bsnes_cplusplus98_libretro.so'
    )
}

function configure_lr-bsnes-cplusplus98() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/bsnes_cplusplus98_libretro.so"
    addSystem "snes"
}
