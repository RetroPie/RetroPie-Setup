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
rp_module_desc="Sega 8/16-bit (MS/GG/SG-1000) emulator - Gearsystem port for libretro."
rp_module_help="ROM Extensions: .sms .gg .sg .mv .bin .rom .zip .7z\n\nCopy your Game Gear roms to $romdir/gamegear\nMasterSystem roms to $romdir/mastersystem\nSG-1000 roms to $romdir/sg-1000"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/gearsystem/master/LICENSE"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-gearsystem() {
    gitPullOrClone "$md_build" https://github.com/drhelius/Gearsystem.git
}

function build_lr-gearsystem() {
    cd "platforms/libretro"
    make clean
    make -j`nproc`
    md_ret_require="$md_build/platforms/libretro/gearsystem_libretro.so"
}

function install_lr-gearsystem() {
    md_ret_files=(
        'platforms/libretro/gearsystem_libretro.so'
    )
}

function configure_lr-gearsystem() {
    for x in mastersystem gamegear sg-1000; do
        mkRomDir "$x"
        ensureSystemretroconfig "$x"

        addEmulator 1 "$md_id" "$x" "$md_inst/gearsystem_libretro.so"
        addSystem "$x"
    done
}
