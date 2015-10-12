#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-fba"
rp_module_desc="Arcade emu - Final Burn Alpha (0.2.97.30) port for libretro"
rp_module_menus="2+"

function depends_lr-fba() {
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_lr-fba() {
    gitPullOrClone "$md_build" https://github.com/libretro/fba-libretro.git
}

function build_lr-fba() {
    cd svn-current/trunk/
    make -f makefile.libretro clean
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        make -f makefile.libretro CC="gcc-4.8" CXX="g++-4.8" platform=armv
    else
        make -f makefile.libretro platform=armv
    fi
    md_ret_require="$md_build/svn-current/trunk/fb_alpha_libretro.so"
}

function install_lr-fba() {
    md_ret_files=(
        'svn-current/trunk/fba.chm'
        'svn-current/trunk/fb_alpha_libretro.so'
        'svn-current/trunk/gamelist-gx.txt'
        'svn-current/trunk/gamelist.txt'
        'svn-current/trunk/whatsnew.html'
        'svn-current/trunk/preset-example.zip'
    )
}

function configure_lr-fba() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/fbalibretro"

    mkRomDir "fba"
    mkRomDir "neogeo"
    ensureSystemretroconfig "fba"
    ensureSystemretroconfig "neogeo"

    delSystem "$md_inst" "fba-libretro"
    addSystem 0 "$md_id" "neogeo" "$md_inst/fb_alpha_libretro.so"
    addSystem 0 "$md_id" "fba arcade" "$md_inst/fb_alpha_libretro.so"
}
