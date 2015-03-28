#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="lr-imame4all"
rp_module_desc="Arcade emu - iMAME4all (based on MAME 0.37b5) port for libretro"
rp_module_menus="2+"

function sources_lr-imame4all() {
    gitPullOrClone "$md_build" git://github.com/libretro/imame4all-libretro.git
    sed -i "s/@mkdir/@mkdir -p/g" makefile.libretro
}

function build_lr-imame4all() {
    make -f makefile.libretro clean
    make -f makefile.libretro ARM=1
    md_ret_require="$md_build/libretro.so"
}

function install_lr-imame4all() {
    md_ret_files=(
        'libretro.so'
        'Readme.txt'
    )
}

function configure_lr-imame4all() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/mamelibretro"

    mkRomDir "mame-mame4all"
    ensureSystemretroconfig "mame-mame4all"

    delSystem "$md_id" "mame-libretro"
    addSystem 0 "$md_id" "mame-mame4all arcade mame" "$md_inst/libretro.so"
}
