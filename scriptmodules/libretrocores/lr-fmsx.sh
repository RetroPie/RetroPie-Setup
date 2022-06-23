#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fmsx"
rp_module_desc="MSX/MSX2 emu - fMSX port for libretro"
rp_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy the fmsx BIOS files to '$biosdir'\n\nCopy your MSX/MSX2 games to $romdir/msx"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fmsx-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/fmsx-libretro.git master"
rp_module_section="opt"

function sources_lr-fmsx() {
    gitPullOrClone
}

function build_lr-fmsx() {
    make clean
    make
    md_ret_require="$md_build/fmsx_libretro.so"
}

function install_lr-fmsx() {
    md_ret_files=(
        'fmsx_libretro.so'
        'README.md'
        'fMSX/ROMs/CARTS.SHA'
    )
}

function configure_lr-fmsx() {
    mkRomDir "msx"
    defaultRAConfig "msx"

    # default to MSX2+ core
    setRetroArchCoreOption "fmsx_mode" "MSX2+"

    addEmulator 0 "$md_id" "msx" "$md_inst/fmsx_libretro.so"
    addSystem "msx"

    [[ "$md_mode" == "remove" ]] && return

    # Copy CARTS.SHA to $biosdir
    cp "$md_inst/CARTS.SHA" "$biosdir/"
    chown $user:$user "$biosdir/CARTS.SHA"
}
