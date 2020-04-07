#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-boom3"
rp_module_desc="Doom 3 engine - dhewm3 port for libretro"
rp_module_help="ROM Extensions: .pk4\n\nCopy your .pk4 roms to $romdir/ports/doom3"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/boom3/master/COPYING.txt"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-boom3() {
    getDepends libjpeg-turbo8-dev libvorbis-dev libogg-dev libopenal-dev libsdl2-dev libcurl4-openssl-dev
}

function sources_lr-boom3() {
    gitPullOrClone "$md_build" https://github.com/libretro/boom3.git 
}

function build_lr-boom3() {
    cd "neo"
    mkdir -p "boom3-cores"
    local params=()
    for i in _ _xp_; do
        if [[ "$i" = _xp_ ]]; then
            params+=(D3XP=ON)
        fi
        make "${params[@]}" clean
        make "${params[@]}" -j`nproc`
        mv "boom3"$i"libretro.so" "boom3-cores"        
        md_ret_require="$md_build/neo/boom3-cores/boom3"$i"libretro.so"
    done
}

function install_lr-boom3() {
    md_ret_files=(
        'neo/boom3-cores/boom3_libretro.so'
        'neo/boom3-cores/boom3_xp_libretro.so'
        'COPYING.txt'
    )
}

function add_games_lr-boom3() {
    local cmd1="$md_inst/boom3_xp_libretro.so"
    local cmd2="$md_inst/boom3_libretro.so"
    declare -A games=(	
        ['base']="Doom 3"
        ['d3xp']="Doom 3 - Resurrection of Evil"
    )
    local game
    local pk4
    for game in "${!games[@]}"; do
        pk4="$romdir/ports/doom3/$game/pak000.pk4"
        if [[ -f "$pk4" ]]; then
	    if [[ "$game" == d3xp ]]; then
                addPort "$md_id-xp" "doom3" "${games[$game]}" "$cmd1" "$pk4"
	    else
                addPort "$md_id" "doom3" "${games[$game]}" "$cmd2" "$pk4"
	    fi
        fi
    done
}

function configure_lr-boom3() {
    setConfigRoot "ports"

    mkRomDir "ports/doom3"
    mkRomDir "ports/doom3/base"
    mkRomDir "ports/doom3/d3xp"

    ensureSystemretroconfig "ports/doom3"

    [[ "$md_mode" == "install" ]] && add_games_lr-boom3

    chown $user:$user "ports/doom3"
}
