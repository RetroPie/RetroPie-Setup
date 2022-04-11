#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-puae2021"
rp_module_desc="P-UAE Amiga emulator port for libretro from 2021 (v2.6.1)"
rp_module_help="ROM Extensions: .adf .uae\n\nCopy your roms to $romdir/amiga and create configs as .uae"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae.git 2.6.1"
rp_module_section="opt"

function sources_lr-puae2021() {
    gitPullOrClone
}

function build_lr-puae2021() {
    make
    md_ret_require="$md_build/puae2021_libretro.so"
}

function install_lr-puae2021() {
    md_ret_files=(
        'puae2021_libretro.so'
        'README.md'
    )
}

function configure_lr-puae2021() {
    mkRomDir "amiga"
    ensureSystemretroconfig "amiga"
    addEmulator 1 "lr-puae2021" "amiga" "$md_inst/puae2021_libretro.so"
    addSystem "amiga"
}
