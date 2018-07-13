#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="linapple"
rp_module_desc="Apple 2 emulator LinApple"
rp_module_help="ROM Extensions: .dsk\n\nCopy your Apple 2 games to $romdir/apple2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dabonetn/linapple-pie/master/LICENSE"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !kms"

function depends_linapple() {
    getDepends libzip-dev libsdl1.2-dev libsdl-image1.2-dev libcurl4-openssl-dev
}

function sources_linapple() {
    gitPullOrClone "$md_build" https://github.com/dabonetn/linapple-pie.git
}

function build_linapple() {
    cd src
    make clean
    make
}

function install_linapple() {
    md_ret_files=(
        'CHANGELOG'
        'INSTALL'
        'LICENSE'
        'linapple'
        'linapple.conf'
        'Master.dsk'
        'README'
        'README-linapple-pie'
    )
}

function configure_linapple() {
    mkRomDir "apple2"
    mkUserDir "$md_conf_root/apple2"

    moveConfigDir "$home/.linapple" "$md_conf_root/apple2"

    if [[ "$md_mode" == "install" ]]; then
        # copy default config/disk if user doesn't have them installed
        local file
        for file in Master.dsk linapple.conf; do
            copyDefaultConfig "$file" "$md_conf_root/apple2/$file"
        done
    fi

    addEmulator 1 "$md_id" "apple2" "pushd $romdir/apple2; $md_inst/linapple -1 %ROM%; popd"
    addSystem "apple2"
}
