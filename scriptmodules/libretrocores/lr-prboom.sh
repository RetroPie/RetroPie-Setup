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
    fi

    if ! echo "e9bf428b73a04423ea7a0e9f4408f71df85ab175 $romdir/ports/doom/freedoom1.wad" | sha1sum -c &>/dev/null; then
        # download (or update) freedoom
        downloadAndExtract "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" "$romdir/ports/doom/" -j -LL
    fi

    mkdir -p "$romdir/ports/doom/addon"
    chown -R $user:$user "$romdir/ports/doom"
}

function _add_games_lr-prboom() {
    local cmd="${@}"
    local addon="$romdir/ports/doom/addon"

    declare -A games=(
        ['doom1.wad']="Doom"
        ['doom2.wad']="Doom II"
        ['doomu.wad']="The Ultimate Doom"
        ['freedoom1.wad']="Freedoom - Phase I"
        ['freedoom2.wad']="Freedoom - Phase II"
        ['tnt.wad']="TNT - Evilution"
        ['plutonia.wad']="The Plutonia Experiment"
    )

    if [[ "$md_id" =~ "zdoom" ]]; then
        games+=(
            ['heretic.wad']="Heretic - Shadow of the Serpent Riders"
            ['hexen.wad']="Hexen - Beyond Heretic"
            ['hexdd.wad']="Hexen - Deathkings of the Dark Citadel"
            ['chex3.wad']="Chex Quest 3"
            ['strife1.wad']="Strife"
        )
    fi

    local game
    local doswad
    local wad
    for game in "${!games[@]}"; do
        doswad="$romdir/ports/doom/${game^^}"
        wad="$romdir/ports/doom/$game"
        if [[ -f "$doswad" ]]; then
            mv "$doswad" "$wad"
        fi
        if [[ -f "$wad" ]]; then
            addPort "$md_id" "doom" "${games[$game]}" "$cmd" "$wad"
            if [[ "$md_id" =~ "zdoom" ]]; then
                addPort "$md_id-addon" "doom" "${games[$game]}" "$cmd -file ${addon}/*" "$wad"
            fi
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
