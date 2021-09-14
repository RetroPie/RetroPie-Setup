#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2010"
rp_module_desc="Arcade emu - MAME 0.139 port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2010-libretro/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/mame2010-libretro.git master"
rp_module_section="opt"

function depends_lr-mame2010() {
    getDepends zlib1g-dev
}

function sources_lr-mame2010() {
    gitPullOrClone
}

function build_lr-mame2010() {
    rpSwap on 750
    make clean
    local params=()
    ! isPlatform "x86" && params+=("VRENDER=soft" "FORCE_DRC_C_BACKEND=1")
    # ARM_ENABLED flag is only used in osinline.h for the YieldProcessor macro and is needed also for aarch64
    if isPlatform "arm" || isPlatform "aarch64"; then
        params+=("ARM_ENABLED=1")
    fi
    isPlatform "64bit" && params+=("PTR64=1")
    make "${params[@]}" ARCHOPTS="$CFLAGS" buildtools
    make "${params[@]}" ARCHOPTS="$CFLAGS"
    rpSwap off
    md_ret_require="$md_build/mame2010_libretro.so"
}

function install_lr-mame2010() {
    md_ret_files=(
        'mame2010_libretro.so'
        'README.md'
    )
}

function configure_lr-mame2010() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2010_libretro.so"
        addSystem "$system"
    done
}
