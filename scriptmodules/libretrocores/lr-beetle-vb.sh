#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-vb"
rp_module_desc="Virtual Boy emulator - Mednafen VB (optimised) port for libretro"
rp_module_help="ROM Extensions: .vb .zip\n\nCopy your Virtual Boy roms to $romdir/virtualboy"
rp_module_section="opt"
rp_module_flags="!armv6"

function sources_lr-beetle-vb() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-vb-libretro.git
}

function build_lr-beetle-vb() {
    make clean
    local params=()
    isPlatform "arm" && params+=("platform=armvneon" "FRONTEND_SUPPORTS_RGB565=1")
    make "${params[@]}" NEED_STEREO_SOUND=1
    md_ret_require="$md_build/mednafen_vb_libretro.so"
}

function install_lr-beetle-vb() {
    md_ret_files=(
        'mednafen_vb_libretro.so'
    )
}

function configure_lr-beetle-vb() {
    mkRomDir "virtualboy"
    ensureSystemretroconfig "virtualboy"

    addSystem 1 "$md_id" "virtualboy" "$md_inst/mednafen_vb_libretro.so"
}
