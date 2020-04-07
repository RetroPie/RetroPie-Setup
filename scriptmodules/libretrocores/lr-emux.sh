#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-emux"
rp_module_desc="SMS/NES/GB emu - Emux port for libretro"
rp_module_help="ROM Extensions: .sms .nes .gb .rom .bin\n\nCopy your mastersystem roms to $romdir/mastersystem\nCopy your NES roms to $romdir/nes\nCopy your Game Boy roms to $romdir/gb\n\nCopy bios.sms (Master System BIOS) and dmg_boot.bin (Game Boy Boot ROM) BIOS files to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/emux/master/COPYING"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_lr-emux() {
    local depends=(libcaca-dev libsdl2-dev)
    getDepends "${depends[@]}"
}

function sources_lr-emux() {
    gitPullOrClone "$md_build" https://github.com/libretro/emux.git
}

function build_lr-emux() {
    cd libretro
    mkdir -p "emux-cores"
    local params=()
    # EMUX CHIP-8 compile, but currently doesn't start.
    for j in chip8 sms gb nes; do
        params+=(MACHINE="$j")
        if ! isPlatform "64bit"; then
	    i="x86"
        else
	    i="x86_64"
        fi
	make -f Makefile.linux_"$i" "${params[@]}" clean
	make -f Makefile.linux_"$i" "${params[@]}"
	mv "emux_"$j"_libretro.linux_"$i".so" "emux_"$j"_libretro.so"
	mv "emux_"$j"_libretro.so" "emux-cores"
	md_ret_require="$md_build/libretro/emux-cores/emux_"$j"_libretro.so"
    done
}

function install_lr-emux() {
    md_ret_files=(
        #'libretro/emux-cores/emux_chip8_libretro.so'
	'libretro/emux-cores/emux_sms_libretro.so'
	'libretro/emux-cores/emux_gb_libretro.so'
	'libretro/emux-cores/emux_nes_libretro.so'
    )
}

function configure_lr-emux() {
    local system
    for system in mastersystem gb nes; do # 'chip8' system wasn't included
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        if [[ $system == "mastersystem" ]]; then
            addEmulator 0 "$md_id" "$system" "$md_inst/emux_sms_libretro.so"
        else
            addEmulator 1 "$md_id" "$system" "$md_inst/emux_"$system"_libretro.so"
        fi
        addSystem "$system"
    done
}
