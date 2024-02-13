#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dsda-doom"
rp_module_desc="DOOM source port based on PrBoom+, focused on speedrunning and QoL"
rp_module_licence="GPL2 https://raw.githubusercontent.com/kraflab/dsda-doom/master/prboom2/COPYING"
rp_module_repo="git https://github.com/kraflab/dsda-doom master"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_dsda-doom() {
    local depends=(cmake libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libogg-dev libmad0-dev libvorbis-dev libzip-dev zlib1g-dev)
    # we need Fluidsynth 2+, check whether the platform has the older libfluidsynth1
    [[ -z "$(dpkg-query -W -f '${Version}' libfluidsynth1)" ]] && depends+=(libfluidsynth-dev)

    getDepends "${depends[@]}"
}

function sources_dsda-doom() {
    gitPullOrClone
}

function build_dsda-doom() {
    rm -rf release && mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release -DWITH_PORTMIDI=OFF)
    # disable fluidsynth when the v1 is found
    [[ -n "$(dpkg-query -W -f '${Version}' libfluidsynth1)" ]] && params+=(-DWITH_FLUIDSYNTH=OFF)
    cmake "${params[@]}" ../prboom2
    make
    md_ret_require="$md_build/release/dsda-doom"
}

function install_dsda-doom() {
    md_ret_files=(
        'release/dsda-doom'
        'release/dsda-doom.wad'
        'README.md'
        'docs'
        'prboom2/COPYING'
        'prboom2/AUTHORS'
    )
}

function add_games_dsda-doom() {
    local params=("-fullscreen" "-width %XRES%" "-height %YRES%")
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"
    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_dsda-doom() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.dsda-doom" "$md_conf_root/doom"

    [[ "$md_mode" == "remove" ]] && return

    game_data_lr-prboom
    add_games_${md_id}
}

