#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-thepowdertoy"
rp_module_desc="Sandbox physics game for libretro"
rp_module_help="Have you ever wanted to blow something up? Or maybe you always dreamt of operating an atomic power plant? Do you have a will to develop your own CPU? The Powder Toy lets you to do all of these, and even more!"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/ThePowderToy/master/LICENSE"
rp_module_section="exp"

function depends_lr-thepowdertoy() {
    local depends=(build-essential cmake)
    getDepends "${depends[@]}"
}

function sources_lr-thepowdertoy() {
    gitPullOrClone "$md_build" https://github.com/libretro/ThePowderToy.git
}

function build_lr-thepowdertoy() {
    mkdir build && cd build
    make clean
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j`nproc`
    md_ret_require="$md_build/build/src/thepowdertoy_libretro.so"
}

function install_lr-thepowdertoy() {
    md_ret_files=(
	'README.md'
	'build/src/thepowdertoy_libretro.so'
    )
}

function configure_lr-thepowdertoy() {
    setConfigRoot "ports"

    addPort "$md_id" "thepowdertoy" "The Powder Toy" "$md_inst/thepowdertoy_libretro.so"

    ensureSystemretroconfig "ports/thepowdertoy"
}
