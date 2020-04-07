#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-simcoupe"
rp_module_desc="SAM Coupe emulator - SimCoupe port for libretro"
rp_module_help="ROM Extensions: .dsk .mgt .sbt .sad\n\nCopy your Sam Coupe games to $romdir/samcoupe"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-simcoupe/master/SimCoupe/License.txt"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-simcoupe() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-simcoupe.git
}

function build_lr-simcoupe() {
    make clean
    make -j`nproc`
    mv "libretro-simcp.so" "simcp_libretro.so"
    md_ret_require="$md_build/simcp_libretro.so"
}

function install_lr-simcoupe() {
    md_ret_files=(
	'SimCoupe/SimCoupe.txt'
	'readme.txt'
	'simcp_libretro.so'
    )
}

function configure_lr-simcoupe() {
    mkRomDir "samcoupe"
    ensureSystemretroconfig "samcoupe"

    addEmulator 1 "$md_id" "samcoupe" "$md_inst/simcp_libretro.so"
    addSystem "samcoupe"
}
