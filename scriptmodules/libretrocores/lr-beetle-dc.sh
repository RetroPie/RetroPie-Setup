#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-dc"
rp_module_desc="Dreamcast emulator - Reicast port for libretro"
rp_module_help="ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-dc/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!mali !armv6"

function _update_hook_lr-beetle-dc() {
    renameModule "lr-reicast" "lr-beetle-dc"
}

function sources_lr-beetle-dc() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-dc.git
    # don't override our C/CXXFLAGS
    sed -i "/^C.*FLAGS.*:=/d" Makefile
}

function build_lr-beetle-dc() {
    make clean
    if isPlatform "rpi"; then
        make platform=rpi
    else
        make
    fi
    md_ret_require="$md_build/beetledc_libretro.so"
}

function install_lr-beetle-dc() {
    md_ret_files=(
        'beetledc_libretro.so'
        'LICENSE'
    )
}

function configure_lr-beetle-dc() {
    mkRomDir "dreamcast"
    ensureSystemretroconfig "dreamcast"

    mkUserDir "$biosdir/dc"

    # system-specific
    iniConfig " = " "" "$configdir/dreamcast/retroarch.cfg"
    iniSet "video_shared_context" "true"

    # segfaults on the rpi without redirecting stdin from </dev/null
    addEmulator 0 "$md_id" "dreamcast" "$md_inst/beetledc_libretro.so </dev/null"
    addSystem "dreamcast"
}
