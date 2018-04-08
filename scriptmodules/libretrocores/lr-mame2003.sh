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
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2003-libretro/master/docs/mame.txt"
rp_module_section="main"

function _get_name_lr-mame2003() {
    echo "${md_id/lr-/}"
}

function sources_lr-mame2003() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2003-libretro.git
}

function build_lr-mame2003() {
    rpSwap on 750
    make clean
    local params=()
    isPlatform "arm" && params+=("ARM=1")
    make ARCH="$CFLAGS" "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/$(_get_name_lr-mame2003)_libretro.so"
}

function install_lr-mame2003() {
    md_ret_files=(
        "$(_get_name_lr-mame2003)_libretro.so"
        'README.md'
        'changed.txt'
        'whatsnew.txt'
        'whatsold.txt'
        'metadata'
    )
}

function configure_lr-mame2003() {
    local name="$(_get_name_lr-mame2003)"

    local mame_dir
    local mame_sub_dir
    for mame_dir in arcade mame-libretro; do
        mkRomDir "$mame_dir"
        mkRomDir "$mame_dir/$name"
        ensureSystemretroconfig "$mame_dir"

        for mame_sub_dir in cfg ctrlr diff hi inp memcard nvram snap; do
            mkRomDir "$mame_dir/$name/$mame_sub_dir"
        done
        
        # copy nvram patches - currently only rungun.nv
        cp "$md_inst/metadata/*.nv" "$mame_dir/$name/$nvram"
        chown $user:$user "$mame_dir/$name/$nvram/*.*"
    done

    mkUserDir "$biosdir/$name"
    mkUserDir "$biosdir/$name/samples"

    # copy hiscore.dat
    cp "$md_inst/metadata/"{hiscore.dat,cheat.dat} "$biosdir/$name/"
    chown $user:$user "$biosdir/$name/"{hiscore.dat,cheat.dat}

    # Set core options
    setRetroArchCoreOption "${name}-skip_disclaimer" "enabled"
    setRetroArchCoreOption "${name}-dcs-speedhack" "enabled"
    setRetroArchCoreOption "${name}-samples" "enabled"

    addEmulator 0 "$md_id" "arcade" "$md_inst/${name}_libretro.so"
    addEmulator 1 "$md_id" "mame-libretro" "$md_inst/${name}_libretro.so"
    addSystem "arcade"
    addSystem "mame-libretro"
}
