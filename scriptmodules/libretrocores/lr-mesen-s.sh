#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mesen-s"
rp_module_desc="Super Nintendo emu - Mesen-S port for libretro"
rp_module_help="ROM Extension: .sfc .smc .fig .swc .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen-S/master/LICENSE"
rp_module_section="opt"
rp_module_flags="!arm"

function sources_lr-mesen-s() {
    gitPullOrClone "$md_build" https://github.com/SourMesen/Mesen-S.git
}

function build_lr-mesen-s() {
    cd Libretro
    make clean
    make -j`nproc`
    md_ret_require="$md_build/Libretro/mesen-s_libretro.so"
}

function install_lr-mesen-s() {
    md_ret_files=(
        'Libretro/mesen-s_libretro.so'
    )
}

function configure_lr-mesen-s() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/mesen-s_libretro.so"
    addSystem "snes"
}
