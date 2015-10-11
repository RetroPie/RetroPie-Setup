#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="basilisk"
rp_module_desc="Macintosh emulator"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_basilisk() {
    getDepends libsdl1.2-dev autoconf automake
}

function sources_basilisk() {
    gitPullOrClone "$md_build" https://github.com/cebix/macemu.git
}

function build_basilisk() {
    cd BasiliskII/src/Unix
    ./autogen.sh --prefix="$md_inst" --enable-sdl-video --enable-sdl-audio --disable-vosf --disable-jit-compiler --without-x --without-mon --without-esd --without-gtk
    make clean
    make
    md_ret_require="$md_build/BasiliskII/src/Unix/BasiliskII"
}

function install_basilisk() {
    cd "BasiliskII/src/Unix"
    make install
}

function configure_basilisk() {
    mkRomDir "macintosh"
    touch "$romdir/macintosh/Start.txt"
    
    mkUserDir "$configdir/macintosh"

    addSystem 1 "$md_id" "macintosh" "$md_inst/bin/BasiliskII --rom $romdir/macintosh/mac.rom --disk $romdir/macintosh/disk.img --config $configdir/macintosh/basiliskii.cfg" "Apple Macintosh" ".txt"
}
