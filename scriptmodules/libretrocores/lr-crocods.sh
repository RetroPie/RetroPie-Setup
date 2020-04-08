#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-crocods"
rp_module_desc="Amstrad CPC emu - CrocoDS port for libretro"
rp_module_help="ROM Extensions: .dsk .sna .kcr\n\nCopy your Amstrad CPC games to $romdir/amstradcpc"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/libretro-crocods/master/LICENSE"
rp_module_section="exp x86=opt"

function depends_lr-crocods() {
    local depends
    isPlatform "arm" && depends+=(gcc-arm-linux-gnueabihf)
    getDepends "${depends[@]}"    
}

function sources_lr-crocods() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-crocods.git
}

function build_lr-crocods() {
    make clean
    make -j`nproc`
    md_ret_require="$md_build/crocods_libretro.so"
}

function install_lr-crocods() {
    md_ret_files=(
        'crocods_libretro.so'
    )
}

function configure_lr-crocods() {
    mkRomDir "amstradcpc"
    ensureSystemretroconfig "amstradcpc"

    addEmulator 1 "$md_id" "amstradcpc" "$md_inst/crocods_libretro.so"
    addSystem "amstradcpc"
}
