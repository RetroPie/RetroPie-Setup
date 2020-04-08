#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes-hd-beta"
rp_module_desc="Super Nintendo emu - bsnes HD (beta version) port for libretro"
rp_module_help="ROM Extensions: .smc .sfc .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DerKoun/bsnes-hd/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!arm"

function sources_lr-bsnes-hd-beta() {
    gitPullOrClone "$md_build" https://github.com/DerKoun/bsnes-hd.git
}

function build_lr-bsnes-hd-beta() {
    cd bsnes
    make clean
    make target=libretro binary=library -j`nproc`
    md_ret_require="$md_build/bsnes/out/bsnes_hd_beta_libretro.so"
}

function install_lr-bsnes-hd-beta() {
    md_ret_files=(
	'bsnes/out/bsnes_hd_beta_libretro.so'
	'LICENSE'
    )
}

function configure_lr-bsnes-hd-beta() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/bsnes_hd_beta_libretro.so"
    addSystem "snes"
}
