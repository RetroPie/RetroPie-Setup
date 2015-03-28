#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-fmsx"
rp_module_desc="MSX/MSX2 emu - fMSX port for libretro"
rp_module_menus="2+"

function sources_lr-fmsx() {
    gitPullOrClone "$md_build" git://github.com/libretro/fmsx-libretro.git
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
    # remove old install folder
    rm -rf "$rootdir/$md_type/fmsx-libretro"

    mkRomDir "msx"
    ensureSystemretroconfig "msx"

    # Copy bios files
    cp "$md_inst/"{*.ROM,*.FNT,*.SHA} "$biosdir/"
    chown $user:$user "$biosdir/"{*.ROM,*.FNT,*.SHA}

    addSystem 1 "$md_id" "msx" "$md_inst/fmsx_libretro.so"
}
