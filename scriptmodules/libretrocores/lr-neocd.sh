#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-neocd"
rp_module_desc="Neo Geo CD Emulator - rewrite of NeoCD for libretro"
rp_module_help="ROM Extension: .chd .cue\n\nCopy your roms to\n$romdir/neogeo\n\nYou will need a minimum of two BIOS files (eg. ng-lo.rom, uni-bioscd.rom) which should be copied to $biosdir/neocd"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/neocd_libretro/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/neocd_libretro.git master"
rp_module_section="exp"

function sources_lr-neocd() {
    gitPullOrClone
}

function build_lr-neocd() {
    make clean
    make
    md_ret_require="$md_build/neocd_libretro.so"
}

function install_lr-neocd() {
    md_ret_files=(
        'LICENSE.md'
        'neocd_libretro.so'
        'README.md'
    )
}

function configure_lr-neocd() {
    mkRomDir "neogeo"
    ensureSystemretroconfig "neogeo"

    addEmulator 0 "$md_id" "neogeo" "$md_inst/neocd_libretro.so"
    addSystem "neogeo"
}
