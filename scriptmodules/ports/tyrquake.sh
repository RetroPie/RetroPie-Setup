#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="tyrquake"
rp_module_desc="Quake 1 engine - TyrQuake port"
rp_module_menus="4+"

function depends_tyrquake() {
    getDepends libsdl2-dev lhasa
}

function sources_tyrquake() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/tyrquake.git
}

function build_tyrquake() {
    local params=(USE_SDL=Y USE_XF86DGA=N)
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/bin/tyr-quake"
}

function install_tyrquake() {
    md_ret_files=(
        'changelog.txt'
        'readme.txt'
        'readme-id.txt'
        'gnu.txt'
        'bin'
    )
}

function configure_tyrquake() {
    addPort "$md_id" "quake" "Quake" "$md_inst/bin/tyr-quake -path $romdir/ports/quake/id1/pak0.pak"
    if isPlatform "x11"; then
        addPort "$md_id-gl" "quake" "Quake" "$md_inst/bin/tyr-glquake -path $romdir/ports/quake/id1/pak0.pak"
    fi

    mkRomDir "ports/quake"

    download_quake_lr-tyrquake
}
