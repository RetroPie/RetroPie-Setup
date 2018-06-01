#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fbalpha"
rp_module_desc="Arcade emu - Final Burn Alpha (v0.2.97.42) port for libretro"
rp_module_help="Previously called lr-fba-next\n\ROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA roms."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fbalpha/master/src/license.txt"
rp_module_section="main"

function _update_hook_lr-fbalpha() {
    # move from old location and update emulators.cfg
    renameModule "lr-fba-next" "lr-fbalpha"
}

function sources_lr-fbalpha() {
    gitPullOrClone "$md_build" https://github.com/libretro/fbalpha.git
}

function build_lr-fbalpha() {
    make -f makefile.libretro clean
    make -f makefile.libretro profile=performance
    md_ret_require="$md_build/fbalpha_libretro.so"
}

function install_lr-fbalpha() {
    md_ret_files=(
        'fba.chm'
        'fbalpha_libretro.so'
        'gamelist.txt'
        'whatsnew.html'
        'preset-example.zip'
        'metadata'
    )
}

function configure_lr-fbalpha() {
    local dir
    for dir in arcade fba neogeo; do
        mkRomDir "$dir"
        ensureSystemretroconfig "$dir"
    done

    # Create samples directory
    mkUserDir "$biosdir/fba"
    mkUserDir "$biosdir/fba/samples"

    # copy hiscore.dat
    cp "$md_inst/metadata/hiscore.dat" "$biosdir/fba/"
    chown $user:$user "$biosdir/fba/hiscore.dat"

    # Set core options
    setRetroArchCoreOption "fba-diagnostic-input" "Hold Start"

    local def=1
    isPlatform "armv6" && def=0
    addEmulator 0 "$md_id" "arcade" "$md_inst/fbalpha_libretro.so"
    addEmulator 0 "$md_id-neocd" "arcade" "$md_inst/fbalpha_libretro.so --subsystem neocd"
    addEmulator $def "$md_id" "neogeo" "$md_inst/fbalpha_libretro.so"
    addEmulator 0 "$md_id-neocd" "neogeo" "$md_inst/fbalpha_libretro.so --subsystem neocd"
    addEmulator $def "$md_id" "fba" "$md_inst/fbalpha_libretro.so"
    addEmulator 0 "$md_id-neocd" "fba" "$md_inst/fbalpha_libretro.so --subsystem neocd"
    addSystem "arcade"
    addSystem "neogeo"
    addSystem "fba"
}
