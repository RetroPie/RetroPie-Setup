#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fbalpha2012-cps1"
rp_module_desc="Capcom CPS1 Arcade emu - Final Burn Alpha (0.2.97.30) port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/cps1 or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fbalpha2012_cps1/master/src/license.txt"
rp_module_section="opt"

function sources_lr-fbalpha2012-cps1() {
    gitPullOrClone "$md_build" https://github.com/libretro/fbalpha2012_cps1.git
}

function build_lr-fbalpha2012-cps1() {
    make -f makefile.libretro clean
    local params=()
    isPlatform "arm" && params+=("platform=armv")
    make -f makefile.libretro "${params[@]}" -j`nproc`
    md_ret_require="$md_build/fbalpha2012_cps1_libretro.so"
}

function install_lr-fbalpha2012-cps1() {
    md_ret_files=(
        'src/license.txt'
        'fbalpha2012_cps1_libretro.so'
    )
}

function configure_lr-fbalpha2012-cps1() {
    local system
    for system in arcade fba cps1; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 0 "$md_id" "$system" "$md_inst/fbalpha2012_cps1_libretro.so"
        addSystem "$system"
    done
}
