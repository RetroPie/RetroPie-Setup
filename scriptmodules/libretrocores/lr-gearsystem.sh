#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-gearsystem"
rp_module_desc="Sega 8 bit emu - Gearsystem port for libretro"
rp_module_help="ROM Extensions: .gg .sg .sms .bin .zip\nCopy your Game Gear roms to $romdir/gamegear\nMasterSystem roms to $romdir/mastersystem\nSG-1000 roms to $romdir/sg-1000"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/Gearsystem/master/LICENSE"
rp_module_repo="git https://github.com/drhelius/Gearsystem.git master"
rp_module_section="exp"

function sources_lr-gearsystem() {
    gitPullOrClone
}

function build_lr-gearsystem() {
    cd platforms/libretro
    make clean
    make
    md_ret_require="$md_build/platforms/libretro/gearsystem_libretro.so"
}

function install_lr-gearsystem() {
    md_ret_files=(
        'platforms/libretro/gearsystem_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-gearsystem() {
    local system
    for system in gamegear mastersystem sg-1000; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/gearsystem_libretro.so"
        addSystem "$system"
    done
}
