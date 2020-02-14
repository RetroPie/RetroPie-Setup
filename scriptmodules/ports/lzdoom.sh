#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lzdoom"
rp_module_desc="lzdoom - DOOM source port (legacy version of GZDoom)"
rp_module_licence="GPL3 https://github.com/drfrag666/gzdoom/blob/g3.3mgw/docs/licenses/README.TXT"
rp_module_section="opt"
rp_module_flags=""

function depends_lzdoom() {
    local depends=(
        libev-dev libfluidsynth-dev libgme-dev libsdl2-dev libmpg123-dev libsndfile1-dev zlib1g-dev libbz2-dev
        timidity freepats cmake libopenal-dev libjpeg-dev libgl1-mesa-dev fluid-soundfont-gm
    )

    getDepends "${depends[@]}"
}

function sources_lzdoom() {
    gitPullOrClone "$md_build" https://github.com/drfrag666/gzdoom "3.84"
}

function build_lzdoom() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    if isPlatform "armv8"; then
        params+=(-DUSE_ARMV8=On)
    fi
    # disable unsafe math optimizations to avoid inaccurate hitscan detection, broken doors, omniscient AI, etc.
    # see: https://forum.zdoom.org/viewtopic.php?f=7&t=57781
    CFLAGS="${CFLAGS//-funsafe-math-optimizations/}" CXXFLAGS="${CXXFLAGS//-funsafe-math-optimizations/}" cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/release/$md_id"
}

function install_lzdoom() {
    md_ret_files=(
        'release/brightmaps.pk3'
        'release/lzdoom'
        'release/lzdoom.pk3'
        'release/lights.pk3'
        'release/game_support.pk3'
        'release/soundfonts'
        'README.md'
    )
}

function add_games_lzdoom() {
    local params=("+fullscreen 1")
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"

    if isPlatform "mesa" || isPlatform "gl"; then
        params+=("+vid_renderer 1")
    elif isPlatform "gles"; then
        params+=("+vid_renderer 0")
    fi

    # FluidSynth is too memory/CPU intensive
    if isPlatform "arm"; then
        params+=("+'snd_mididevice -3'")
    fi

    if isPlatform "kms"; then
        params+=("+vid_vsync 1" "-width %XRES%" "-height %YRES%")
    fi

    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_lzdoom() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.config/$md_id" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_${md_id}
}
