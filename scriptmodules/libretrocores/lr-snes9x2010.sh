#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-snes9x2010"
rp_module_desc="Super Nintendo emu - Snes9x 1.52 based port for libretro"
rp_module_help="Previously called lr-snes9x-next\n\nROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_section="main"
rp_module_flags="!armv6"

function _update_hook_lr-snes9x2010() {
    # move from old location and update emulators.cfg
    renameModule "lr-snes9x-next" "lr-snes9x2010"
}

function sources_lr-snes9x2010() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x2010.git
}

function build_lr-snes9x2010() {
    make -f Makefile.libretro clean
    if isPlatform "neon"; then
        make -f Makefile.libretro platform=armvneon
    else
        make -f Makefile.libretro
    fi
    md_ret_require="$md_build/snes9x2010_libretro.so"
}

function install_lr-snes9x2010() {
    md_ret_files=(
        'snes9x2010_libretro.so'
        'docs'
    )
}

function configure_lr-snes9x2010() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addSystem 1 "$md_id" "snes" "$md_inst/snes9x2010_libretro.so"
}
