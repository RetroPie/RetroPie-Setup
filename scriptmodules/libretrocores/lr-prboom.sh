#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-prboom"
rp_module_desc="Doom/Doom II engine - PrBoom port for libretro"
rp_module_section="opt"

function sources_lr-prboom() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-prboom.git
}

function build_lr-prboom() {
    make clean
    make
    md_ret_require="$md_build/prboom_libretro.so"
}

function install_lr-prboom() {
    md_ret_files=(
        'prboom_libretro.so'
        'prboom.wad'
    )
}

function game_data_lr-prboom() {
    if [[ ! -f "$romdir/ports/doom/doom1.wad" ]]; then
        # download doom 1 shareware
        wget -nv -O "$romdir/ports/doom/doom1.wad" "$__archive_url/doom1.wad"
        chown $user:$user "$romdir/ports/doom/doom1.wad"
    fi
}

function configure_lr-prboom() {
    setConfigRoot "ports"

    addPort "$md_id" "doom" "Doom" "$emudir/retroarch/bin/retroarch -L $md_inst/prboom_libretro.so --config $md_conf_root/doom/retroarch.cfg $romdir/ports/doom/doom1.wad"

    mkRomDir "ports/doom"
    ensureSystemretroconfig "ports/doom"

    cp prboom.wad "$romdir/ports/doom/"
    chown $user:$user "$romdir/ports/doom/prboom.wad"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom
}
