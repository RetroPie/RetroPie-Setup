#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mupen64plus"
rp_module_desc="N64 emu - Mupen64Plus + GLideN64 for libretro"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_section="main"
rp_module_flags="!mali"

function _update_hook_lr-mupen64plus() {
    # move from old location and update emulators.cfg
    # we need to first move lr-mupen64plus out of the way if it exists
    renameModule "lr-mupen64plus" "lr-parallel-n64"
    renameModule "lr-glupen64" "lr-mupen64plus"
}

function depends_lr-mupen64plus() {
    local depends=(flex bison libpng12-dev)
    isPlatform "x86" && depends+=(nasm)
    getDepends "${depends[@]}"
}

function sources_lr-mupen64plus() {
    gitPullOrClone "$md_build" https://github.com/libretro/mupen64plus-libretro.git
}

function build_lr-mupen64plus() {
    rpSwap on 750
    make clean
    if isPlatform "rpi"; then
        make platform="$__platform"
    else
        make
    fi
    rpSwap off
    md_ret_require="$md_build/mupen64plus_libretro.so"
}

function install_lr-mupen64plus() {
    md_ret_files=(
        'mupen64plus_libretro.so'
        'README.md'
        'BUILDING.md'
    )
}

function configure_lr-mupen64plus() {
    mkRomDir "n64"
    ensureSystemretroconfig "n64"

    addEmulator 0 "$md_id" "n64" "$md_inst/mupen64plus_libretro.so"
    addSystem "n64"
}
