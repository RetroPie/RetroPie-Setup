#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="smw"
rp_module_desc="Super Mario War - A fan-made multiplayer Super Mario Bros. style deathmatch game"
rp_module_licence="GPL2 https://smwstuff.net"
rp_module_repo="git https://github.com/mmatyas/supermariowar master"
rp_module_section="opt"
rp_module_flags="sdl2"

function depends_smw() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev zlib1g-dev
}

function sources_smw() {
    gitPullOrClone
}

function build_smw() {
    local params=(-DUSE_SDL2_LIBS=ON -DSMW_INSTALL_PORTABLE=ON)
    isPlatform "gles2" && params+=(-DSDL2_FORCE_GLES=ON)
    rm -fr build
    mkdir -p build && cd build
    cmake .. "${params[@]}"
    make smw
    md_ret_require="$md_build/build/smw"
}

function install_smw() {
    md_ret_files=(
        "build/smw"
        "data"
        "docs"
        "README.md"
        "CREDITS"
    )
}

function configure_smw() {
    addPort "$md_id" "smw" "Super Mario War" "$md_inst/smw"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.smw" "$md_conf_root/smw"
    # try to migrate existing settings to the new conf folder
    if [[ -f "$md_conf_root/smw/.smw.options.bin" ]] ; then
         mv "$md_conf_root/smw/.smw.options.bin" "$md_conf_root/smw/options.bin"
    fi
}
