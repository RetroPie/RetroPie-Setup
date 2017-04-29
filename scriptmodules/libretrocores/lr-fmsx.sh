#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fmsx"
rp_module_desc="MSX/MSX2 emu - fMSX port for libretro"
rp_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fmsx-libretro/master/fMSX/fMSX.html"
rp_module_section="opt"

function sources_lr-fmsx() {
    gitPullOrClone "$md_build" https://github.com/libretro/fmsx-libretro.git
}

function build_lr-fmsx() {
    make clean
    make
    md_ret_require="$md_build/fmsx_libretro.so"
}

function install_lr-fmsx() {
    md_ret_files=(
        'fmsx_libretro.so'
        'README.md'
        'fMSX/ROMs/CARTS.SHA'
        'fMSX/ROMs/CYRILLIC.FNT'
        'fMSX/ROMs/DISK.ROM'
        'fMSX/ROMs/FMPAC.ROM'
        'fMSX/ROMs/FMPAC16.ROM'
        'fMSX/ROMs/ITALIC.FNT'
        'fMSX/ROMs/KANJI.ROM'
        'fMSX/ROMs/MSX.ROM'
        'fMSX/ROMs/MSX2.ROM'
        'fMSX/ROMs/MSX2EXT.ROM'
        'fMSX/ROMs/MSX2P.ROM'
        'fMSX/ROMs/MSX2PEXT.ROM'
        'fMSX/ROMs/MSXDOS2.ROM'
        'fMSX/ROMs/PAINTER.ROM'
        'fMSX/ROMs/RS232.ROM'
    )
}

function configure_lr-fmsx() {
    mkRomDir "msx"
    ensureSystemretroconfig "msx"

    # default to MSX2+ core
    setRetroArchCoreOption "fmsx_mode" "MSX2+"

    # Copy bios files
    cp "$md_inst/"{*.ROM,*.FNT,*.SHA} "$biosdir/"
    chown $user:$user "$biosdir/"{*.ROM,*.FNT,*.SHA}

    addEmulator 0 "$md_id" "msx" "$md_inst/fmsx_libretro.so"
    addSystem "msx"
}
