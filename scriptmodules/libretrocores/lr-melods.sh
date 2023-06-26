#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-melonds"
rp_module_desc="NDS/DSI emu - MelonDS"
rp_module_help="ROM Extensions: .nds .zip\n\nCopy your Nintendo DS/DSI ROMs to $romdir/nds"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/melonDS/master/LICENSE"
rp_module_repo="git https://github.com/libretro/melonDS.git"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function _params_lr-melonds() {
    local params=()
    isPlatform "arm" && params+=("platform=unixarmvhardfloat")
    isPlatform "aarch64" && params+=("DISABLE_GL=1")
    echo "${params[@]}"
}

function depends_lr-melonds() {
    getDepends cmake extra-cmake-modules libcurl4-gnutls-dev libpcap0.8-dev libsdl2-dev qtbase5-dev qtbase5-private-dev qtmultimedia5-dev libslirp-dev libarchive-dev libzstd-dev
}

function sources_lr-melonds() {
    gitPullOrClone
}

function build_lr-melonds() {
    cd melonDS
    make clean
    make $(_params_lr-melonds)
    md_ret_require="$md_build/melonDS_libretro.so"
}

function install_lr-melonds() {
    md_ret_files=(
        'melonDS_libretro.so'
    )
}

function configure_lr-melonds() {
    mkRomDir "nds"
    defaultRAConfig "nds"

    addEmulator 0 "$md_id" "nds" "$md_inst/melonDS_libretro.so"
    addSystem "nds"
}
