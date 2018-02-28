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
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-prboom/master/COPYING"
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

function _add_games_lr-prboom() {
    local cmd="$1"
    declare -A games=(
        ['doom1']="Doom"
        ['doom2']="Doom 2"
        ['tnt']="TNT - Evilution"
        ['plutonia']="The Plutonia Experiment"
    )

    if [[ "$md_id" == "zdoom" ]]; then
        games+=(
            ['heretic']="Heretic - Shadow of the Serpent Riders"
            ['hexen']="Hexen - Beyond Heretic"
            ['hexdd']="Hexen - Deathkings of the Dark Citadel"
            ['chex3']="Chex Quest 3"
            ['strife1']="Strife"
        )
    fi
    local game
    local doswad
    local wad
    for game in "${!games[@]}"; do
        doswad="$romdir/ports/doom/${game^^}.WAD"
        wad="$romdir/ports/doom/$game.wad"
        if [[ -f "$doswad" ]]; then
            mv "$doswad" "$wad"
        fi
        if [[ -f "$wad" ]]; then
            addPort "$md_id" "doom" "${games[$game]}" "$cmd" "$wad"
        fi
    done
}

function add_games_lr-prboom() {
    _add_games_lr-prboom "$md_inst/prboom_libretro.so"
}

function configure_lr-prboom() {
    setConfigRoot "ports"

    mkRomDir "ports/doom"
    ensureSystemretroconfig "ports/doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_lr-prboom

    cp prboom.wad "$romdir/ports/doom/"
    chown $user:$user "$romdir/ports/doom/prboom.wad"
}
