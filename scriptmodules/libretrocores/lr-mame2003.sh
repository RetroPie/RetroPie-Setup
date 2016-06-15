#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2003"
rp_module_desc="Arcade emu - MAME 0.78 port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_section="main"

function depends_lr-mame2003() {
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_lr-mame2003() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2003-libretro.git
    # quieter build
    sed -i "s/-Wcast-align//" Makefile
}

function build_lr-mame2003() {
    make clean
    local params=()
    isPlatform "arm" && params+=("ARM=1")
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        make ARCH="$CFLAGS" CC="gcc-4.8" CXX="g++-4.8" "${params[@]}"
    else
        make ARCH="$CFLAGS" "${params[@]}"
    fi
}

function install_lr-mame2003() {
    md_ret_files=(
        'mame2003_libretro.so'
        'README.md'
        'changed.txt'
        'whatsnew.txt'
        'whatsold.txt'
    )
}

function configure_lr-mame2003() {
    # remove old core library
    rm -f "$md_inst/mame078_libretro.so"

    mkUserDir "$biosdir/mame2003/"
    mkUserDir "$biosdir/mame2003/samples/"

    local mame_dir
    for mame_dir in arcade mame-libretro
    do
        mkRomDir "$mame_dir"
        ensureSystemretroconfig "$mame_dir"

        local mame_sub_dir
        for mame_sub_dir in cfg ctrlr diff hi inp memcard nvram snap
        do
            mkRomDir "$mame_dir/mame2003/$mame_sub_dir"
        done
    done

    # Set core options
    setRetroArchCoreOption "mame2003-skip_disclaimer" "enabled"
    setRetroArchCoreOption "mame2003-dcs-speedhack" "enabled"
    setRetroArchCoreOption "mame2003-samples" "enabled"

    addSystem 0 "$md_id" "arcade" "$md_inst/mame2003_libretro.so"
    addSystem 1 "$md_id" "mame-libretro arcade mame" "$md_inst/mame2003_libretro.so"
}
