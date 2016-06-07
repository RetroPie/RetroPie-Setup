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
rp_module_section="opt"
rp_module_flags="dispmanx !mali"

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
    mkdir -p "$md_inst/ftp/cache"
    mkdir -p "$md_inst/images"
    md_ret_files=(
        'CHANGELOG'
        'INSTALL'
        'LICENSE'
        'linapple'
        'Master.dsk'
        'README'
        'README-linapple-pie'
        'linapple.conf'
    )
}

function configure_linapple() {
    mkRomDir "apple2"
    mkUserDir "$md_conf_root/apple2"

    # install linapple.conf under another name as we will copy it
    cp -v "$md_inst/linapple.conf" "$md_inst/linapple.conf.sample"
    cp -vf "$md_inst/Master.dsk" "$md_conf_root/apple2/Master.dsk"

    # if the user doesn't already have a config, we will copy the default.
    if [[ ! -f "$md_conf_root/apple2/linapple.conf" ]]; then
        cp -v "linapple.conf.sample" "$md_conf_root/apple2/linapple.conf"
    fi
    moveConfigFile "linapple.conf" "$md_conf_root/apple2/linapple.conf"
    moveConfigFile "Master.dsk" "$md_conf_root/apple2/Master.dsk"

    addSystem 1 "$md_id" "apple2" "$md_inst/linapple -1 %ROM%" "Apple II" ".po .dsk .nib"

    moveConfigDir "$home/.linapple" "$md_conf_root/apple2"
    chown -R $user:$user "$md_conf_root/apple2"
}
