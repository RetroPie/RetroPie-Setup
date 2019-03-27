#!/bin/bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-ppsspp"
rp_module_desc="PlayStation Portable emu - PPSSPP port for libretro"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/ppsspp/master/LICENSE.TXT"
rp_module_section="opt"
rp_module_flags="!aarch64"

function depends_lr-ppsspp() {
    depends_ppsspp
}

function sources_lr-ppsspp() {
    sources_ppsspp
}

function build_lr-ppsspp() {
    build_ppsspp
}

function install_lr-ppsspp() {
    md_ret_files=(
        'lr-ppsspp/lib/ppsspp_libretro.so'
        'lr-ppsspp/assets'
    )
}

function configure_lr-ppsspp() {
    mkRomDir "psp"
    ensureSystemretroconfig "psp"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$biosdir/PPSSPP"
        cp -Rv "$md_inst/assets/"* "$biosdir/PPSSPP/"
        chown -R $user:$user "$biosdir/PPSSPP"
    fi

    addEmulator 1 "$md_id" "psp" "$md_inst/ppsspp_libretro.so"
    addSystem "psp"
}
