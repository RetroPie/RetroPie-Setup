#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-tic80"
rp_module_desc="TIC-80 fantasy computer - port for libretro"
rp_module_help="ROM Extensions: .tic .zip\n\nCopy your roms to $romdir/tic80\n\n"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/TIC-80/master/LICENSE"
rp_module_repo="git https://github.com/libretro/TIC-80.git master"
rp_module_section="exp"

function depends_lr-tic80() {
    getDepends cmake
}

function sources_lr-tic80() {
    gitPullOrClone
}

function build_lr-tic80() {
    rm -rf retropie
    mkdir -p retropie
    cd retropie
    cmake -DBUILD_PLAYER=OFF -DBUILD_SOKOL=OFF -DBUILD_SDL=OFF -DBUILD_DEMO_CARTS=OFF -DBUILD_LIBRETRO=ON ..
    make
    md_ret_require="$md_build/retropie/lib/tic80_libretro.so"
}


function install_lr-tic80() {
    md_ret_files=(
        'retropie/lib/tic80_libretro.so'
        'README.md'
        'LICENSE'
    )
}

function configure_lr-tic80() {
    mkRomDir "tic80"
    ensureSystemretroconfig "tic80"
    addEmulator 1 "$md_id" "tic80" "$md_inst/tic80_libretro.so"
    addSystem "tic80" "TIC-80"
}
