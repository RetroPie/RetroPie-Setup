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
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/COPYING"
rp_module_repo="git https://github.com/libretro/mame.git master :_get_version_lr-mame"
rp_module_section="exp"
rp_module_flags="!:\$__gcc_version:-lt:7"

function _get_version_lr-mame() {
    local tagname
    if [[ "$__gcc_version" -lt 10 ]]; then
        tagname="lrmame0264"
    fi
    echo "$tagname"
}
function _get_params_lr-mame() {
    local params=(OSD=retro RETRO=1 PYTHON_EXECUTABLE=python3 NOWERROR=1 OS=linux OPTIMIZE=2 TARGETOS=linux CONFIG=libretro NO_USE_MIDI=1 NO_USE_PORTAUDIO=1 TARGET=mame)
    isPlatform "64bit" && params+=(PTR64=1)
    echo "${params[@]}"
}

function depends_lr-mame() {
    local depends=(libasound2-dev)
    isPlatform "gles" && depends+=(libgles2-mesa-dev)
    isPlatform "gl" && depends+=(libglu1-mesa-dev)
    getDepends "${depends[@]}"
}

function sources_lr-mame() {
    gitPullOrClone
}

function build_lr-mame() {
    if isPlatform "64bit"; then
        rpSwap on 10240
    else
        rpSwap on 6144
    fi
    local params=($(_get_params_lr-mame) SUBTARGET=arcade)
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/mamearcade_libretro.so"
}

function install_lr-mame() {
    md_ret_files=(
        'COPYING'
        'mamearcade_libretro.so'
        'README.md'
    )
}

function configure_lr-mame() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mamearcade_libretro.so"
        addSystem "$system"
    done
}
