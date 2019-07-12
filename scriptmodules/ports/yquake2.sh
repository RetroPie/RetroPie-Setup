#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="yquake2"
rp_module_desc="yquake2 - The Yamagi Quake II client"
rp_module_licence="GPL2 https://raw.githubusercontent.com/yquake2/yquake2/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function depends_yquake2() {
    local depends=(libgl1-mesa-dev libglu1-mesa-dev libogg-dev libopenal-dev libsdl2-dev libvorbis-dev zlib1g-dev)

    getDepends "${depends[@]}"
}

function sources_yquake2() {
    gitPullOrClone "$md_build" https://github.com/yquake2/yquake2.git
    # workaround for hang on startup
    sed -i "$md_build/src/backends/unix/system.c" -e '/setegid/d' -e '/setreuid/d'
}

function build_yquake2() {
    rm -rf release
    cmake .
    make clean
    make
    md_ret_require="$md_build/release/quake2"
}

function install_yquake2() {
    md_ret_files=(
        'release/baseq2'
        'release/q2ded'
        'release/quake2'
        'release/ref_gl1.so'
        'release/ref_gl3.so'
        'release/ref_soft.so'
        'LICENSE'
        'README.md'
    )
}

function add_games_yquake2() {
    local cmd="$1"
    declare -A games=(
        ['baseq2/pak0']="Quake II"
        ['rogue/pak0']="Quake II - Ground Zero"
        ['xatrix/pak0']="Quake II - The Reckoning"
    )

    local game
    local pak
    for game in "${!games[@]}"; do
        pak="$romdir/ports/quake2/$game.pak"
        if [[ -f "$pak" ]]; then
            addPort "$md_id" "quake2" "${games[$game]}" "$cmd" "${game%%/*}"
        fi
    done
}

function game_data_yquake2() {
    local unwanted

    if [[ ! -f "$romdir/ports/quake2/baseq2/pak1.pak" && ! -f "$romdir/ports/quake2/baseq2/pak0.pak" ]]; then
        # get shareware game data
        downloadAndExtract "https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe" "$romdir/ports/quake2/baseq2" -j -LL
    fi

    # remove files that are likely to cause conflicts or unwanted default settings
    for unwanted in $(find "$romdir/ports/quake2" -maxdepth 2 -name "*.so" -o -name "*.cfg" -o -name "*.dll" -o -name "*.exe"); do
        rm -f "$unwanted"
    done

    chown -R $user:$user "$romdir/ports/quake2"
}


function configure_yquake2() {
    local params=()

    if isPlatform "x11"; then
        params+=("+set vid_renderer gl3")
    elif isPlatform "mesa"; then
        params+=("+set vid_renderer gl1")
    else
        params+=("+set vid_renderer soft")
    fi

    if isPlatform "kms"; then
        params+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%")
    fi

    mkRomDir "ports/quake2"

    moveConfigDir "$home/.yq2" "$md_conf_root/quake2/yquake2"

    [[ "$md_mode" == "install" ]] && game_data_yquake2
    add_games_yquake2 "$md_inst/quake2 -datadir $romdir/ports/quake2 ${params[*]} +set game %ROM%"
}
