#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fuse"
rp_module_desc="ZX Spectrum emu - Fuse port for libretro"
rp_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/fuse-libretro/master/LICENSE"
rp_module_section="main"

function sources_lr-fuse() {
    gitPullOrClone "$md_build" https://github.com/libretro/fuse-libretro.git
}

function build_lr-fuse() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/fuse_libretro.so"
}

function install_lr-fuse() {
    md_ret_files=(
        'fuse_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-fuse() {
    mkRomDir "zxspectrum"
    ensureSystemretroconfig "zxspectrum"

    # default to 128k spectrum
    setRetroArchCoreOption "fuse_machine" "Spectrum 128K"

    addEmulator 1 "$md_id" "zxspectrum" "$md_inst/fuse_libretro.so"
    addSystem "zxspectrum"
}
