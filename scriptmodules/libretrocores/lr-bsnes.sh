#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes"
rp_module_desc="Super Nintendo Emulator - bsnes port for libretro (v115)"
rp_module_help="ROM Extensions: .bml .smc .sfc .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes/master/LICENSE.txt"
rp_module_repo="git https://github.com/libretro/bsnes.git master"
rp_module_section="opt"
rp_module_flags="!armv6 !:\$__gcc_version:-lt:7"

function sources_lr-bsnes() {
    gitPullOrClone
}

function build_lr-bsnes() {
    local params=(target="libretro" build="release" binary="library")
    make -C bsnes clean "${params[@]}"
    make -C bsnes "${params[@]}"
    md_ret_require="$md_build/bsnes/out/bsnes_libretro.so"
}

function install_lr-bsnes() {
    md_ret_files=(
        'bsnes/out/bsnes_libretro.so'
        'LICENSE.txt'
        'GPLv3.txt'
        'CREDITS.md'
        'README.md'
    )
}

function configure_lr-bsnes() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/bsnes_libretro.so"
    addSystem "snes"
}
