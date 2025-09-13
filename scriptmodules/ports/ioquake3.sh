#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ioquake3"
rp_module_desc="Quake 3 source port"
rp_module_licence="GPL2 https://github.com/ioquake/ioq3/blob/master/COPYING.txt"
rp_module_repo="git https://github.com/ioquake/ioq3 main"
rp_module_section="opt"
rp_module_flags="!videocore"

function depends_ioquake3() {
    getDepends cmake libsdl2-dev libgl1-mesa-dev
}

function sources_ioquake3() {
    gitPullOrClone
}

function build_ioquake3() {
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build --clean-first
    md_ret_require="$md_build/build/Release/ioquake3"
}

function install_ioquake3() {
    md_ret_files=(
        "build/Release/ioq3ded"
        "build/Release/ioquake3"
        "build/Release/renderer_opengl1.so"
        "build/Release/renderer_opengl2.so"
    )
}

function configure_ioquake3() {
    local launcher=("$md_inst/ioquake3")
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")

    addPort "$md_id" "quake3" "Quake III Arena" "${launcher[*]}"

    mkRomDir "ports/quake3"

    moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3"
    moveConfigDir "$home/.q3a" "$md_conf_root/ioquake3"

    [[ "$md_mode" == "install" ]] && game_data_quake3
}
