#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-reicast"
rp_module_desc="Dreamcast emu - Reicast port for libretro"
rp_module_help="ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/reicast-emulator/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!arm"

function sources_lr-reicast() {
    gitPullOrClone "$md_build" https://github.com/libretro/reicast-emulator.git
}

function build_lr-reicast() {
    make clean
    make
    md_ret_require="$md_build/reicast_libretro.so"
}

function install_lr-reicast() {
    md_ret_files=(
        'reicast_libretro.so'
    )
}

function configure_lr-reicast() {
    mkRomDir "dreamcast"
    ensureSystemretroconfig "dreamcast"

    mkUserDir "$biosdir/dc"

    # system-specific
    iniConfig " = " "" "$configdir/dreamcast/retroarch.cfg"
    iniSet "video_shared_context" "true"

    addEmulator 0 "$md_id" "dreamcast" "$md_inst/reicast_libretro.so"
    addSystem "dreamcast"
}
