#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-x1"
rp_module_desc="Sharp X1 emulator - X Millenium port for libretro"
rp_module_help="ROM Extensions: .dx1 .zip .2d .2hd .tfd .d88 .88d .hdm .xdf .dup .cmd\n\nCopy your X1 roms to $romdir/x1\n\nCopy the required BIOS files IPLROM.X1 and IPLROM.X1T to $biosdir"
rp_module_licence="BSD 3-Clause https://raw.githubusercontent.com/libretro/xmil-libretro/master/LICENSE"
rp_module_section="exp"

function sources_lr-x1() {
    gitPullOrClone "$md_build" https://github.com/libretro/xmil-libretro.git
}

function build_lr-x1() {
    cd libretro
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/libretro/x1_libretro.so"
}

function install_lr-x1() {
    md_ret_files=(
        'libretro/x1_libretro.so'
    )
}

function configure_lr-x1() {
    mkRomDir "x1"
    ensureSystemretroconfig "x1"

    addEmulator 1 "$md_id" "x1" "$md_inst/x1_libretro.so"
    addSystem "x1"
}
