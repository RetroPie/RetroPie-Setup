#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-snes9x2005"
rp_module_desc="Super Nintendo emu - Snes9x 1.43 based port for libretro"
rp_module_help="Previously called lr-catsfc\n\nROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x2005/master/copyright"
rp_module_section="main"

function _update_hook_lr-snes9x2005() {
    # move from old location and update emulators.cfg
    renameModule "lr-catsfc" "lr-snes9x2005"
}

function sources_lr-snes9x2005() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x2005.git
}

function build_lr-snes9x2005() {
    make clean
    make
    md_ret_require="$md_build/snes9x2005_libretro.so"
}

function install_lr-snes9x2005() {
    md_ret_files=(
        'snes9x2005_libretro.so'
    )
}

function configure_lr-snes9x2005() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/snes9x2005_libretro.so"
    addSystem "snes"
}
