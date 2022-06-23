#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-smsplus-gx"
rp_module_desc="Sega Master System & Game Gear emu - SMSPlus (enhanced) port for libretro"
rp_module_help="ROM Extensions: .gg .sms .bin .zip\nCopy your Game Gear roms to $romdir/gamegear\nMasterSystem roms to $romdir/mastersystem"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/smsplus-gx/master/docs/license"
rp_module_repo="git https://github.com/libretro/smsplus-gx.git master"
rp_module_section="exp"

function sources_lr-smsplus-gx() {
    gitPullOrClone
}

function build_lr-smsplus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/smsplus_libretro.so"
}

function install_lr-smsplus-gx() {
    md_ret_files=(
        'smsplus_libretro.so'
        'docs/license'
        'README.md'
    )
}

function configure_lr-smsplus-gx() {
    local system
    for system in gamegear mastersystem; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/smsplus_libretro.so"
        addSystem "$system"
    done
}
