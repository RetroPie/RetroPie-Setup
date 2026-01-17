#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fbalpha2012"
rp_module_desc="Arcade emu - Final Burn Alpha (0.2.97.30) port for libretro"
rp_module_help="Previously called lr-fba\n\nROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA roms."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fbalpha2012/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/fbalpha2012.git master"
rp_module_section="opt armv6=main"

function _update_hook_lr-fbalpha2012() {
    # move from old location and update emulators.cfg
    renameModule "lr-fba" "lr-fbalpha2012"
}

function sources_lr-fbalpha2012() {
    gitPullOrClone
}

function build_lr-fbalpha2012() {
    cd svn-current/trunk/
    make -f makefile.libretro clean
    local params=()
    isPlatform "arm" && params+=("platform=armv")
    make -f makefile.libretro "${params[@]}"
    md_ret_require="$md_build/svn-current/trunk/fbalpha2012_libretro.so"
}

function install_lr-fbalpha2012() {
    md_ret_files=(
        'svn-current/trunk/fba.chm'
        'svn-current/trunk/fbalpha2012_libretro.so'
        'svn-current/trunk/gamelist-gx.txt'
        'svn-current/trunk/gamelist.txt'
        'svn-current/trunk/whatsnew.html'
        'svn-current/trunk/preset-example.zip'
    )
}

function configure_lr-fbalpha2012() {
    local system
    for system in arcade fba neogeo; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/fbalpha2012_libretro.so"
        addSystem "$system"
    done
}
