#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lzdoom-system"
rp_module_desc="lzdoom-system - DOOM source port (legacy version of GZDoom)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drfrag666/gzdoom/master/LICENSE"
rp_module_repo="git https://github.com/drfrag666/gzdoom 3.88b"
rp_module_section="opt"
rp_module_flags=""

function depends_lzdoom-system() {
    local depends=(
        libev-dev libfluidsynth-dev libgme-dev libsdl2-dev libmpg123-dev libsndfile1-dev zlib1g-dev libbz2-dev
        timidity freepats cmake libopenal-dev libjpeg-dev libgl1-mesa-dev fluid-soundfont-gm
    )

    getDepends "${depends[@]}"
}

function sources_lzdoom-system() {
    gitPullOrClone
    if isPlatform "arm"; then
        # patch the CMake build file to remove the ARMv8 options, we handle `gcc`'s CPU flags ourselves
        applyPatch "$md_data/01_remove_cmake_arm_options.diff"
        # patch the 21.06 version of LZMA-SDK to disable the CRC32 ARMv8 intrinsics forced for ARM CPUs
        applyPatch "$md_data/02_lzma_sdk_dont_force_arm_crc32.diff"
    fi
}

function build_lzdoom-system() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DPK3_QUIET_ZIPDIR=ON -DCMAKE_BUILD_TYPE=Release)
    # Note: `-funsafe-math-optimizations` should be avoided, see: https://forum.zdoom.org/viewtopic.php?f=7&t=57781
    cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/release/$md_id"
}

function install_lzdoom-system() {
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

function add_games_lzdoom-system() {
    local params=("+fullscreen 1")
    local launcher_prefix="DOOMWADDIR=$romdir/doom"

    if isPlatform "mesa" || isPlatform "gl"; then
        params+=("+vid_renderer 1")
    elif isPlatform "gles"; then
        params+=("+vid_renderer 0")
    fi

    # FluidSynth is too memory/CPU intensive
    if isPlatform "arm"; then
        params+=("+snd_mididevice -3")
    fi

    if isPlatform "kms"; then
        params+=("+vid_vsync 1" "-width %XRES%" "-height %YRES%")
    fi

    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_lzdoom-system() {
    mkRomDir "doom"
    mkUserDir "$home/.config"
    setConfigRoot ""
    addEmulator 1 "lzdoom" "doom" "$md_inst/lzdoom -iwad %ROM%"
    addSystem "doom" "DOOM" ".pk3 .wad"
    moveConfigDir "$home/.config/lzdoom" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_${md_id}
}
