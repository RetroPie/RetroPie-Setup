#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mesen"
rp_module_desc="NES emu - mesen port for libretro"
rp_module_help="ROM Extensions: .nes .zip\n\nCopy your NES roms to $romdir/nes\n\nFor the Famicom Disk System copy your roms to $romdir/fds\n\nFor the Famicom Disk System copy the required BIOS file disksys.rom to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/nestopia/master/COPYING"
rp_module_section="exp"

function sources_lr-mesen() {
    gitPullOrClone "$md_build" https://github.com/libretro/mesen.git
}

function build_lr-mesen() {
    cd Libretro
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/Libretro/mesen_libretro.so"
}

function install_lr-mesen() {
    md_ret_files=(
        'Libretro/mesen_libretro.so'
        
    )
}

function configure_lr-mesen() {
    mkRomDir "nes"
    mkRomDir "fds"
    mkUserDir "$biosdir/HdPacks"
    ensureSystemretroconfig "nes"
    ensureSystemretroconfig "fds"

    

    addEmulator 0 "$md_id" "nes" "$md_inst/mesen_libretro.so"
    addEmulator 1 "$md_id" "fds" "$md_inst/mesen_libretro.so"
    addSystem "nes"
    addSystem "fds"
}
