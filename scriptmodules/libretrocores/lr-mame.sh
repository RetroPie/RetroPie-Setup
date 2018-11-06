#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame"
rp_module_desc="MAME emulator - MAME (current) port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/LICENSE.md"
rp_module_section="exp"

function _get_params_lr-mame() {
    local params=(OSD=retro RETRO=1 NOWERROR=1 OS=linux TARGETOS=linux CONFIG=libretro NO_USE_MIDI=1 TARGET=mame)
    isPlatform "64bit" && params+=(PTR64=1)
    echo "${params[@]}"
}

function depends_lr-mame() {
    if compareVersions $__gcc_version lt 5.0.0; then
        md_ret_errors+=("Sorry, you need an OS with gcc 5.0 or newer to compile lr-mame")
        return 1
    fi
}

function sources_lr-mame() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame.git
}

function build_lr-mame() {
    rpSwap on 2000
    local params=($(_get_params_lr-mame) SUBTARGET=arcade)
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/mamearcade_libretro.so"
}

function install_lr-mame() {
    md_ret_files=(
        'mamearcade_libretro.so'
    )
}

function configure_lr-mame() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mamearcade_libretro.so"
        addSystem "$system"
    done
}
