#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-beetle-vb"
rp_module_desc="Virtual Boy emulator - Mednafen VB (optimised) port for libretro"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function sources_lr-beetle-vb() {
    gitPullOrClone "$md_build" git://github.com/libretro/beetle-vb-libretro.git
}

function build_lr-beetle-vb() {
    make clean
    make platform=armvneon NEED_STEREO_SOUND=1 FRONTEND_SUPPORTS_RGB565=1
    md_ret_require="$md_build/mednafen_vb_libretro.so"
}

function install_lr-beetle-vb() {
    md_ret_files=(
        'mednafen_vb_libretro.so'
        'README.md'
    )
}

function configure_lr-beetle-vb() {
    mkRomDir "virtualboy"
    ensureSystemretroconfig "virtualboy"

    addSystem 1 "$md_id" "virtualboy" "$md_inst/mednafen_vb_libretro.so"
}
