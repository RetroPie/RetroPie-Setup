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
rp_module_repo="git https://github.com/ioquake/ioq3 main :_get_commit_ioquake3"
rp_module_section="opt"
rp_module_flags="!videocore"

function _get_commit_ioquake3() {
    # On Buster and Bullseye we have to build using make (an old method) instead of cmake.
    # This is because ioquake3 requires CMake 3.25 or higher which is satisfied only on Bookworm.
    if [[ "$__os_debian_ver" -lt 12 ]]; then
        # This is the latest commit before the Makefile was removed.
        echo 7ac92951f2da597611ab4525023979df2f92047a
    fi
}

function depends_ioquake3() {
    getDepends cmake libsdl2-dev libgl1-mesa-dev
}

function sources_ioquake3() {
    gitPullOrClone
}

function build_ioquake3() {
    if [[ "$__os_debian_ver" -lt 12 ]]; then
        make clean
        I_ACKNOWLEDGE_THE_MAKEFILE_IS_DEPRECATED=1 make
    else
        cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
        cmake --build build --clean-first
    fi
    md_ret_require="$md_build/$(_release_dir)/ioquake3"
}

function _release_dir() {
    if [[ "$__os_debian_ver" -lt 12 ]]; then
        # exact parsing from Makefile
        local arch_ioquake3="$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/' | sed -e 's/aarch64/arm64/')"
        echo "build/release-linux-${arch_ioquake3}"
    else
        echo "build/Release"
    fi
}

function install_ioquake3() {
    md_ret_files=(
        "$(_release_dir)/ioq3ded"
        "$(_release_dir)/ioquake3"
        "$(_release_dir)/renderer_opengl1.so"
        "$(_release_dir)/renderer_opengl2.so"
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
