#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="vvvvvv"
rp_module_desc="VVVVVV - 2D puzzle game by Terry Cavanagh"
rp_module_licence="NONCOM https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md"
rp_module_help="Copy data.zip from a purchased or Make and Play edition of VVVVVV to $romdir/ports/vvvvvv"
rp_module_section="exp"

function depends_vvvvvv() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev
}

function sources_vvvvvv() {
    gitPullOrClone "$md_build" https://github.com/TerryCavanagh/VVVVVV
    # default to fullscreen
    sed -i "s/fullscreen = false/fullscreen = true/" "$md_build/desktop_version/src/Game.cpp"
}

function build_vvvvvv() {
    cmake desktop_version
    rpSwap on 1500
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/VVVVVV"
}

function install_vvvvvv() {
    md_ret_files=(
        'LICENSE.md'
        'VVVVVV'
    )
}

function configure_vvvvvv() {
    addPort "$md_id" "vvvvvv" "VVVVVV" "$md_inst/VVVVVV"

    [[ "$md_mode" != "install" ]] && return

    moveConfigDir "$home/.local/share/VVVVVV" "$md_conf_root/vvvvvv"

    mkUserDir "$romdir/ports/$md_id"
    # symlink game data
    ln -snf "$romdir/ports/$md_id/data.zip" "$md_inst/data.zip"
}
