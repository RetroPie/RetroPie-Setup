#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-vbam"
rp_module_desc="Game Boy (Color/Advance) emu - VBA-M port for libretro"
rp_module_help="ROM Extensions: .dmg .gb .gbc .cgb .sgb .gba .zip .7z\n\nCopy your Gameboy roms to $romdir/gb.\nCopy your Gameboy Color roms to $romdir/gbc.\nCopy your Gameboy Advance roms to $romdir/gba.\n\nCopy the optional BIOS files gb_bios.bin, gbc_bios.bin and gba_bios.bin to $biosdir.\n\nSuper Game Boy support (borders, palette)."
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vbam-libretro/master/doc/gpl.txt"
rp_module_section="opt"

function sources_lr-vbam() {
    gitPullOrClone "$md_build" https://github.com/libretro/vbam-libretro.git
}

function build_lr-vbam() {
    cd src/libretro
    make
    md_ret_require="$md_build/src/libretro/vbam_libretro.so"
}

function install_lr-vbam() {
    md_ret_files=(
        'src/libretro/vbam_libretro.so'
    )
}

function configure_lr-vbam() {
    local system
    for system in gb gbc gba; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 0 "$md_id" "$system" "$md_inst/vbam_libretro.so"
        addSystem "$system"
    done
}
