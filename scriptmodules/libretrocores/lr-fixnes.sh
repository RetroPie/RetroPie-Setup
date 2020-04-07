#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fixnes"
rp_module_desc="NES emu - fixNES port for libretro"
rp_module_help="ROM Extensions: .nes .fds .qd .nsf .zip .7z\n\nCopy your NES roms to $romdir/gb\nCopy your FDS roms to $romdir/gbc\n\nCopy disksys.rom (Family Computer Disk System BIOS) to $biosdir"
rp_module_licence="MIT https://raw.githubusercontent.com/FIX94/fixNES/master/LICENSE"
rp_module_section="exp x86=opt"
rp_module_flags="!rpi4 !mali"

function sources_lr-fixnes() {
    gitPullOrClone "$md_build" https://github.com/FIX94/fixNES.git
}

function build_lr-fixnes() {
    cd libretro
    make clean
    make -j`nproc`
    md_ret_require="$md_build/libretro/fixnes_libretro.so"
}

function install_lr-fixnes() {
    md_ret_files=(
	'LICENSE'
	'README.md'
	'libretro/fixnes_libretro.so'
    )
}

function configure_lr-fixnes() {
    for x in fds nes; do
        mkRomDir "$x"
        ensureSystemretroconfig "$x"

        addEmulator 1 "$md_id" "$x" "$md_inst/fixnes_libretro.so"
        addSystem "$x"
    done
}
