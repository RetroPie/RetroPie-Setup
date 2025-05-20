#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bennugd"
rp_module_desc="BennuGD as a libretro core"
rp_module_help="ROM Extensions: .dat .dcb\n\nCopy your games to $romdir/bennugd"
rp_module_licence="GPL3"
rp_module_repo="git https://github.com/diekleinekuh/BennuGD_libretro.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-bennugd() {
    getDepends cmake libssl-dev libogg-dev libvorbis-dev libmikmod-dev libpng-dev zlib1g-dev libfreetype6-dev
}


function sources_lr-bennugd() {
    gitPullOrClone
}

function build_lr-bennugd() {
    mkdir build
    cd build
    cmake .. -DNO_SYSTEM_DEPENDENCIES=OFF -DCMAKE_BUILD_TYPE=Release
    cmake  --build . --clean-first -j
    md_ret_require="$md_build/build/bennugd_libretro.so"
}

function install_lr-bennugd() {
    md_ret_files=(
        'build/bennugd_libretro.so'
    )
}

function configure_lr-bennugd() {
    mkRomDir "bennugd"
    defaultRAConfig "bennugd"

    addEmulator 1 "$md_id" "bennugd" "$md_inst/bennugd_libretro.so"

    addSystem "bennugd" "BennuGD" ".dat .dcb"
}
