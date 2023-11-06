#!/usr/bin/env bash

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
rp_module_repo="git https://github.com/hrydgard/ppsspp.git :_get_release_ppsspp"
rp_module_section="opt"
rp_module_flags=""

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
        'ppsspp/lib/ppsspp_libretro.so'
        'ppsspp/assets'
    )
}

function configure_lr-ppsspp() {
    mkRomDir "psp"
    defaultRAConfig "psp"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$biosdir/PPSSPP"
        cp -Rv "$md_inst/assets/"* "$biosdir/PPSSPP/"
        chown -R $user:$user "$biosdir/PPSSPP"

        # the core needs a save file directory, use the same folder as standalone 'ppsspp'
        iniConfig " = " "" "$configdir/psp/retroarch.cfg"
        iniSet "savefile_directory" "$home/.config/ppsspp"
        moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
    fi

    addEmulator 1 "$md_id" "psp" "$md_inst/ppsspp_libretro.so"
    addSystem "psp"

    # if we are removing the last remaining psp emu - remove the symlink
    if [[ "$md_mode" == "remove" ]]; then
        if [[ -h "$home/.config/ppsspp" && ! -f "$md_conf_root/psp/emulators.cfg" ]]; then
            rm -f "$home/.config/ppsspp"
        fi
    fi
}
