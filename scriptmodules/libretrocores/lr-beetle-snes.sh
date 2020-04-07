#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-snes"
rp_module_desc="Super Nintendo emu - Mednafen bSNES (fork of bsnes v0.59) port for libretro"
rp_module_help="ROM Extensions: .smc .sfc .fig .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-bsnes-libretro/master/COPYING"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-beetle-snes() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-bsnes-libretro.git
}

function build_lr-beetle-snes() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/mednafen_snes_libretro.so"
}

function install_lr-beetle-snes() {
    md_ret_files=(
        'COPYING'
        'mednafen_snes_libretro.so'
    )
}

function configure_lr-beetle-snes() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/mednafen_snes_libretro.so"
    addSystem "snes"
}
