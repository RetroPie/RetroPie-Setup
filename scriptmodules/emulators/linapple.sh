#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="linapple"
rp_module_desc="Apple 2 emulator LinApple"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_linapple() {
    getDepends libzip2 libzip-dev libsdl1.2-dev libcurl4-openssl-dev
}

function sources_linapple() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/linapple-src_2a.tar.bz2 | tar -xvj --strip-components=1
    addLineToFile "#include <unistd.h>" "src/Timer.h"
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
        'charset40.bmp'
        'font.bmp'
        'icon.bmp'
        'splash.bmp'
        'Master.dsk'
        'README'
    )
    # install linapple.conf under another name as we will copy it
    cp -v "$md_build/linapple.conf" "$md_inst/linapple.conf.sample"
}

function configure_linapple() {
    mkRomDir "apple2"

    chown -R $user:$user "$md_inst"

    rm -f "$romdir/apple2/Start.txt"
    cat > "$romdir/apple2/+Start LinApple.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./linapple
popd
_EOF_
    chmod +x "$romdir/apple2/+Start LinApple.sh"

    mkUserDir "$configdir/apple2"

    # if the user doesn't already have a config, we will copy the default.
    if [[ ! -f "$configdir/apple2/linapple.conf" ]]; then
        cp -v "linapple.conf.sample" "$configdir/apple2/linapple.conf"
        iniConfig " = " "" "$configdir/apple2/linapple.conf"
        iniSet "Joystick 0" "1"
        iniSet "Joystick 1" "1"
    fi
    ln -sf "$configdir/apple2/linapple.conf"
    chown $user:$user "$configdir/apple2/linapple.conf"

    addSystem 1 "$md_id" "apple2" "$romdir/apple2/+Start\ LinApple.sh" "Apple II" ".sh"
}
