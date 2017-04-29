#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-virtualjaguar"
rp_module_desc="Atari Jaguar emu - Virtual Jaguar (optimised) port for libretro"
rp_module_help="ROM Extensions: .j64 .jag .zip\n\nCopy your Atari Jaguar roms to $romdir/atarijaguar"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/virtualjaguar-libretro/master/docs/GPLv3"
rp_module_section="exp"
rp_module_flags="!armv6"

function sources_lr-virtualjaguar() {
    gitPullOrClone "$md_build" https://github.com/libretro/virtualjaguar-libretro.git
}

function build_lr-virtualjaguar() {
    make clean
    make
    md_ret_require="$md_build/virtualjaguar_libretro.so"
}

function install_lr-virtualjaguar() {
    md_ret_files=(
        'virtualjaguar_libretro.so'
        'README.md'
    )
}

function configure_lr-virtualjaguar() {
    mkRomDir "atarijaguar"
    ensureSystemretroconfig "atarijaguar"

    addEmulator 1 "$md_id" "atarijaguar" "$md_inst/virtualjaguar_libretro.so"
    addSystem "atarijaguar"
}
