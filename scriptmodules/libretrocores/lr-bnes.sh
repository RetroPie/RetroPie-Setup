#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bnes"
rp_module_desc="NES emu - bNES port for libretro"
rp_module_help="ROM Extensions: .nes .zip .7z\n\nCopy your NES roms to $romdir/nes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bnes-libretro/master/license"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-bnes() {
    gitPullOrClone "$md_build" https://github.com/libretro/bnes-libretro.git
}

function build_lr-bnes() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/bnes_libretro.so"
}

function install_lr-bnes() {
    md_ret_files=(
        'bnes_libretro.so'
        'license'
    )
}

function configure_lr-bnes() {
    mkRomDir "nes"
    ensureSystemretroconfig "nes"

    addEmulator 1 "$md_id" "nes" "$md_inst/bnes_libretro.so"
    addSystem "nes"
}
