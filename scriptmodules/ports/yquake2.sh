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
rp_module_repo="git https://github.com/yquake2/yquake2.git QUAKE2_8_50"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_yquake2() {
    local depends=(libgl1-mesa-dev libglu1-mesa-dev libogg-dev libopenal-dev libsdl2-dev libvorbis-dev zlib1g-dev libcurl4-openssl-dev)

    getDepends "${depends[@]}"
}

function sources_yquake2() {
    gitPullOrClone
    # get the add-ons sources
    gitPullOrClone "$md_build/xatrix" "https://github.com/yquake2/xatrix" "XATRIX_2_14"
    gitPullOrClone "$md_build/rogue" "https://github.com/yquake2/rogue" "ROGUE_2_13"

    # 1st enables Guide+Start to quit. 2nd restores buttons to SDL2 style (from SDL3).
    applyPatch "$md_data/hotkey_exit.diff"
    applyPatch "$md_data/sdl2_joylabels.diff"
}

function build_yquake2() {
    local params=(config client game ref_soft)
    local repo

    isPlatform "gl" || isPlatform "mesa" && params+=(ref_gl1)
    isPlatform "gl3" && params+=(ref_gl3)
    isPlatform "gles" && [[ "$__os_debian_ver" -lt 12 ]] && params+=(ref_gles1)
    isPlatform "gles3" && params+=(ref_gles3)

    make clean
    make ${params[@]}

    # build the add-ons source
    for repo in 'xatrix' 'rogue'; do
        make -C "$repo" clean
        make -C "$repo"
        # add-ons: rename the 'release' folder so it's installed under '$repo' by the install func
        [[ -f "$repo/release/game.so" ]] && mv "$repo/release" "$repo/$repo"
    done
    md_ret_require="$md_build/release/quake2"
}

function install_yquake2() {
    md_ret_files=(
        'release/baseq2'
        'release/quake2'
        'release/ref_soft.so'
        'LICENSE'
        'README.md'
        'xatrix/xatrix'
        'rogue/rogue'
    )

    isPlatform "gl" || isPlatform "mesa" && md_ret_files+=('release/ref_gl1.so')
    isPlatform "gl3" && md_ret_files+=('release/ref_gl3.so')
    isPlatform "gles" && [[ "$__os_debian_ver" -lt 12 ]] && md_ret_files+=('release/ref_gles1.so')
    isPlatform "gles3" && md_ret_files+=('release/ref_gles3.so')
}

function add_games_yquake2() {
    local cmd="$1"
    declare -A games=(
        ['baseq2']="Quake II"
        ['xatrix']="Quake II XP1 - The Reckoning"
        ['rogue']="Quake II XP2 - Ground Zero"
    )

    local game
    for game in "${!games[@]}"; do
        if [[ -f "$romdir/ports/quake2/$game/pak0.pak" ]]; then
            addPort "$md_id" "quake2" "${games[$game]}" "$cmd" "$game"
        fi
    done
}

function game_data_yquake2() {
    if [[ ! -f "$romdir/ports/quake2/baseq2/pak1.pak" && ! -f "$romdir/ports/quake2/baseq2/pak0.pak" ]]; then
        # get shareware game data
        downloadAndExtract "https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe" "$romdir/ports/quake2/baseq2" -j -LL
        # remove files that are likely to cause conflicts or unwanted default settings
        local unwanted
        for unwanted in $(find "$romdir/ports/quake2" -maxdepth 2 -name "*.so" -o -name "*.cfg" -o -name "*.dll" -o -name "*.exe"); do
            rm -f "$unwanted"
        done
    fi

    chown -R "$__user":"$__group" "$romdir/ports/quake2"
}


function configure_yquake2() {
    local config="$md_conf_root/quake2/yquake2/baseq2/yq2.cfg"
    local renderer="soft"

    mkRomDir "ports/quake2"

    moveConfigDir "$home/.yq2" "$md_conf_root/quake2/yquake2"
    mkUserDir "$md_conf_root/quake2/yquake2/baseq2"

    copyDefaultConfig "$md_data/yq2.cfg" "$config"
    iniConfig " " '"' "$config"

    if isPlatform "gl3"; then
        renderer="gl3"
    elif isPlatform "gles3"; then
        renderer="gles3"
    elif isPlatform "gles" && [[ "$__os_debian_ver" -lt 11 ]]; then
        renderer="gles1"
        iniSet "set gl1_pointparameters" "1"
    elif isPlatform "gl" || isPlatform "mesa"; then
        renderer="gl1"
    fi

    iniSet "set vid_renderer" "$renderer"

    [[ "$md_mode" == "install" ]] && game_data_yquake2
    add_games_yquake2 "$md_inst/quake2 -datadir $romdir/ports/quake2 +set game %ROM%"
}
