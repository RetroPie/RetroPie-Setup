#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="darkplaces-quake"
rp_module_desc="Quake 1 engine - Darkplaces Quake port with GLES rendering"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xonotic/darkplaces/master/COPYING"
rp_module_repo="git https://github.com/xonotic/darkplaces.git div0-stable"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_darkplaces-quake() {
    local depends=(libsdl2-dev libjpeg-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    getDepends "${depends[@]}"
}

function sources_darkplaces-quake() {
    gitPullOrClone
    isPlatform "rpi" && applyPatch "$md_data/01_rpi_fixes.diff"
    applyPatch "$md_data/02_makefile_fixes.diff"
    # comment out problematic invariant qualifier which fails to compile with mesa gles on rpi4
    isPlatform "rpi4" && sed -i 's#^"invariant#"//invariant#' "$md_build/shader_glsl.h"
}

function build_darkplaces-quake() {
    local force_opengl="$1"
    # on the rpi4, we build gles first, and then force an opengl build (which is the default)
    [[ -z "$force_opengl" ]] && force_opengl=0
    local params=(OPTIM_RELEASE="")
    if isPlatform "gles" && [[ "$force_opengl" -eq 0 ]]; then
        params+=(SDLCONFIG_UNIXCFLAGS_X11="-DUSE_GLES2")
        if isPlatform "videocore"; then
            params+=(SDLCONFIG_UNIXLIBS_X11="-L /opt/vc/lib -lbrcmGLESv2")
        else
            params+=(SDLCONFIG_UNIXLIBS_X11="-lGLESv2")
        fi
    fi
    make clean
    make sdl-release "${params[@]}"
    if isPlatform "rpi4" && [[ "$force_opengl" -eq 0 ]]; then
        mv "$md_build/darkplaces-sdl" "$md_build/darkplaces-sdl-gles"
        # revert rpi4 gles change which commented out invariant line from earlier.
        sed -i 's#^"//invariant#"invariant#' "$md_build/shader_glsl.h"
        # rebuild opengl version on rpi4
        build_darkplaces-quake 1
        md_ret_require+=("$md_build/darkplaces-sdl-gles")
    else
        md_ret_require+=("$md_build/darkplaces-sdl")
    fi
}

function install_darkplaces-quake() {
    md_ret_files=(
        'darkplaces.txt'
        'darkplaces-sdl'
        'COPYING'
    )
    isPlatform "rpi4" && md_ret_files+=("darkplaces-sdl-gles")
}

function add_games_darkplaces-quake() {
    local params=(-basedir "$romdir/ports/quake" -game %QUAKEDIR%)
    isPlatform "kms" && params+=("+vid_vsync 1")
    if isPlatform "rpi4"; then
       addEmulator 0 "$md_id-gles" "quake" "$md_inst/darkplaces-sdl-gles ${params[*]}"
    fi
    _add_games_lr-tyrquake "$md_inst/darkplaces-sdl ${params[*]}"
}

function configure_darkplaces-quake() {
    mkRomDir "ports/quake"

    [[ "$md_mode" == "install" ]] && game_data_lr-tyrquake

    add_games_darkplaces-quake

    moveConfigDir "$home/.darkplaces" "$md_conf_root/quake/darkplaces"
}
