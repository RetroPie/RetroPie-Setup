#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-redream"
rp_module_desc="Dreamcast emulator - redream port for libretro"
rp_module_help="ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/redream/master/LICENSE.txt"
rp_module_section="exp"
rp_module_flags="!arm !aarch64"

function sources_lr-redream() {
    gitPullOrClone "$md_build" https://github.com/libretro/redream.git
}

function build_lr-redream() {
    cd deps/libretro
    make clean
    make
    md_ret_require="$md_build/deps/libretro/redream_libretro.so"
}

function install_lr-redream() {
    md_ret_files=(
        'deps/libretro/redream_libretro.so'
    )
}

function configure_lr-redream() {
    mkRomDir "dreamcast"
    ensureSystemretroconfig "dreamcast"

    mkUserDir "$biosdir/dc"

    addEmulator 0 "$md_id" "dreamcast" "$md_inst/redream_libretro.so"
    addSystem "dreamcast"
}
