#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-uae4arm"
rp_module_desc="Uae4arm port for libretro"
rp_module_help="ROM Extensions: .adf .uae .lha .ipf .iso\n\nCopy your Amigas games to $romdir/amiga."
rp_module_licence="GPL2"
rp_module_repo="git https://github.com/Chips-fr/uae4arm-rpi.git master"
rp_module_section="exp"
rp_module_flags="!all arm aarch64"

function depends_lr-uae4arm() {
    getDepends zlib1g-dev libmpg123-dev libflac-dev
}

function sources_lr-uae4arm() {
    gitPullOrClone
}

function build_lr-uae4arm() {
    make -f Makefile.libretro clean
    local params=(platform=unix)
    isPlatform "neon" && params=(platform=unix-neon)
    isPlatform "aarch64" && params=(platform=unix-aarch64)
    make -f Makefile.libretro "${params[@]}"
    md_ret_require="$md_build/uae4arm_libretro.so"
}

function install_lr-uae4arm() {
    md_ret_files=(
        'uae4arm_libretro.so'
        'README.md'
    )
}

function configure_lr-uae4arm() {
    mkRomDir "amiga"
    defaultRAConfig "amiga"
    addEmulator 1 "$md_id" "amiga" "$md_inst/uae4arm_libretro.so"
    addSystem "amiga"
}
