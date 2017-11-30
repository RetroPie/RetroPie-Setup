#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dosbox"
rp_module_desc="DOS emulator"
rp_module_help="ROM Extensions: .bat .com .exe .sh\n\nCopy your DOS games to $ROMDIR/pc"
rp_module_licence="https://raw.githubusercontent.com/libretro/dosbox-libretro/master/COPYING"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-dosbox() {
    gitPullOrClone "$md_build" https://github.com/libretro/dosbox-libretro.git
}

function build_lr-dosbox() {
    local params=()
    if isPlatform "arm"; then
        if isPlatform "armv6"; then
            params+="WITH_DYNAREC=oldarm"
        else
            params+="WITH_DYNAREC=arm"
        fi
    fi
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/dosbox_libretro.so"
}

function install_lr-dosbox() {
    md_ret_files=(
        'COPYING'
        'dosbox_libretro.so'
        'README'
    )
}

function configure_lr-dosbox() {
    mkRomDir "pc"
    ensureSystemretroconfig "pc"

    addEmulator 0 "$md_id" "pc" "$md_inst/dosbox_libretro.so"
    addSystem "pc"
}
