#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-ngp"
rp_module_desc="Neo Geo Pocket(Color)emu - Mednafen Neo Geo Pocket core port for libretro"
rp_module_help="ROM Extensions: .ngc .ngp .zip\n\nCopy your Neo Geo Pocket roms to $romdir/ngp\n\nCopy your Neo Geo Pocket Color roms to $romdir/ngpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-ngp-libretro/master/COPYING"
rp_module_section="main"

function _update_hook_lr-beetle-ngp() {
    # move from old location and update emulators.cfg
    renameModule "lr-mednafen-ngp" "lr-beetle-ngp"
}

function sources_lr-beetle-ngp() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-ngp-libretro.git
}

function build_lr-beetle-ngp() {
    make clean
    make
    md_ret_require="$md_build/mednafen_ngp_libretro.so"
}

function install_lr-beetle-ngp() {
    md_ret_files=(
        'mednafen_ngp_libretro.so'
    )
}

function configure_lr-beetle-ngp() {
    local system
    for system in ngp ngpc; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 1 "$md_id" "$system" "$md_inst/mednafen_ngp_libretro.so"
        addSystem "$system"
    done

}
