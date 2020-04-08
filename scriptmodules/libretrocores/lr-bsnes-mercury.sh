#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes-mercury"
rp_module_desc="Super Nintendo emu - bsnes (v0.94 Mercury) port for libretro"
rp_module_help="ROM Extensions: .smc .sfc .bml .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes-mercury/master/LICENSE"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-bsnes-mercury() {
    gitPullOrClone "$md_build" https://github.com/libretro/bsnes-mercury.git
}

function build_lr-bsnes-mercury() {
    make clean
    for i in accuracy balanced performance; do
        make profile=${i} -j`nproc`
        md_ret_require="$md_build/out/bsnes_mercury_${i}_libretro.so"
    done
}

function install_lr-bsnes-mercury() {
    md_ret_files=(
        'out/bsnes_mercury_accuracy_libretro.so'
        'out/bsnes_mercury_balanced_libretro.so'
        'out/bsnes_mercury_performance_libretro.so'
        'LICENSE'
    )
}

function configure_lr-bsnes-mercury() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"
    for j in accuracy balanced performance; do
        addEmulator 1 "$md_id-${j}" "snes" "$md_inst/bsnes_mercury_${j}_libretro.so"
    done
    addSystem "snes"
}
