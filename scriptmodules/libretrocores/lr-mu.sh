#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mu"
rp_module_desc="Palm OS emu - Mu port for libretro"
rp_module_help="ROM Extensions: .prc .pqa .img .zip\n\nCopy your Palm OS roms to $romdir/palmos\n\nThe Palm OS requires the BIOS files palmos41-en-m515.rom (Palm OS 4.1) copied to $biosdir.\n\nOptional BIOS files:\npalmos40-en-m500.rom (Palm OS 4.0)\npalmos52-en-t3.rom (Palm OS 5.2.1)\npalmos60-en-t3.rom (Palm OS 6.0)\nbootloader-dbvz.rom (MC68VZ328 UART Bootloader)"
rp_module_licence="NONCOM https://raw.githubusercontent.com/meepingsnesroms/Mu/master/readme.md"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-mu() {
    gitPullOrClone "$md_build" https://github.com/meepingsnesroms/Mu.git
}

function build_lr-mu() {
    cd libretroBuildSystem
    make clean
    make -j`nproc`
    md_ret_require="$md_build/libretroBuildSystem/mu_libretro.so"
}

function install_lr-mu() {
    md_ret_files=(
	'readme.md'
	'libretroBuildSystem/mu_libretro.so'
    )
}

function configure_lr-mu() {
    mkRomDir "palm"
    ensureSystemretroconfig "palm"

    addEmulator 1 "$md_id" "palm" "$md_inst/mu_libretro.so"
    addSystem "palm"
}
