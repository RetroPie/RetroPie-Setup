#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fba-next"
rp_module_desc="Arcade emu - Final Burn Alpha (0.2.97.38) port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA roms."
rp_module_section="main"

function depends_lr-fba-next() {
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_lr-fba-next() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-fba.git
}

function build_lr-fba-next() {
    make -f makefile.libretro clean
    local params=()
    isPlatform "arm" && params+=("platform=armv")
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        make -f makefile.libretro CC="gcc-4.8" CXX="g++-4.8" "${params[@]}" profile=performance
    else
        make -f makefile.libretro "${params[@]}" profile=performance
    fi
    md_ret_require="$md_build/fba_libretro.so"
}

function install_lr-fba-next() {
    md_ret_files=(
        'fba.chm'
        'fba_libretro.so'
        'gamelist.txt'
        'whatsnew.html'
        'preset-example.zip'
    )
}

function configure_lr-fba-next() {
    mkRomDir "arcade"
    mkRomDir "fba"
    mkRomDir "neogeo"
    ensureSystemretroconfig "arcade"
    ensureSystemretroconfig "fba"
    ensureSystemretroconfig "neogeo"

    # Create samples directory
    mkUserDir "$biosdir/fba/samples/"

    # Set core options
    setRetroArchCoreOption "fba-diagnostic-input" "Hold Start"

    local def=1
    isPlatform "armv6" && def=0
    addSystem 0 "$md_id" "arcade" "$md_inst/fba_libretro.so"
    addSystem $def "$md_id" "neogeo" "$md_inst/fba_libretro.so"
    addSystem $def "$md_id" "fba arcade" "$md_inst/fba_libretro.so"
}
