#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-higan"
rp_module_desc="Super Nintendo emu - Higan (v1.06) port for libretro"
rp_module_help="ROM Extensions: .smc .sfc .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/higan/master/LICENSE.txt"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-higan() {
    gitPullOrClone "$md_build" https://gitlab.com/higan/higan.git libretro
}

function build_lr-higan() {
    cd higan
    make clean
    make target=libretro binary=library -j`nproc`
    md_ret_require="$md_build/higan/out/higan_sfc_libretro.so"
}

function install_lr-higan() {
    md_ret_files=(
	'higan/out/higan_sfc_libretro.so'
	'GPLv3.txt'
	'LICENSE.txt'
    )
}

function configure_lr-higan() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/higan_sfc_libretro.so"
    addSystem "snes"
}
