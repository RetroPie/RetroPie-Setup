#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="basilisk"
rp_module_desc="Macintosh emulator"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_basilisk() {
    getDepends libsdl1.2-dev autoconf automake
}

function sources_basilisk() {
    gitPullOrClone "$md_build" git://github.com/cebix/macemu.git
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
