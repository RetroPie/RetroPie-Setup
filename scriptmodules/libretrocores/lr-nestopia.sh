#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-nestopia"
rp_module_desc="NES emu - Nestopia (enhanced) port for libretro"
rp_module_help="ROM Extensions: .nes .zip\n\nCopy your NES roms to $romdir/nes\n\nFor the Famicom Disk System copy your roms to $romdir/fds\n\nFor the Famicom Disk System copy the required BIOS file disksys.rom to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/nestopia/master/COPYING"
rp_module_section="main"

function sources_lr-nestopia() {
    gitPullOrClone "$md_build" https://github.com/libretro/nestopia.git
}

function build_lr-nestopia() {
    cd libretro
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/libretro/nestopia_libretro.so"
}

function install_lr-nestopia() {
    md_ret_files=(
        'libretro/nestopia_libretro.so'
        'NstDatabase.xml'
        'README.md'
        'ChangeLog'
        'readme.html'
        'COPYING'
        'AUTHORS'
    )
}

function configure_lr-nestopia() {
    mkRomDir "nes"
    mkRomDir "fds"
    ensureSystemretroconfig "nes"
    ensureSystemretroconfig "fds"

    cp NstDatabase.xml "$biosdir/"
    chown $user:$user "$biosdir/NstDatabase.xml"

    addEmulator 0 "$md_id" "nes" "$md_inst/nestopia_libretro.so"
    addEmulator 1 "$md_id" "fds" "$md_inst/nestopia_libretro.so"
    addSystem "nes"
    addSystem "fds"
}
