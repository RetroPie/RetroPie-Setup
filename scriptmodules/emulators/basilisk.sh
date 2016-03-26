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
rp_module_flags="dispmanx !mali"

function depends_basilisk() {
    local depends=(libsdl1.2-dev autoconf automake)
    isPlatform "x11" && depends+=(libgtk2.0-dev)
    getDepends "${depends[@]}"
}

function sources_basilisk() {
    gitPullOrClone "$md_build" https://github.com/cebix/macemu.git
}

function build_basilisk() {
    cd BasiliskII/src/Unix
    local params=(--enable-sdl-video --enable-sdl-audio --disable-vosf --without-mon --without-esd)
    ! isPlatform "x86" && params+=(--disable-jit-compiler)
    ! isPlatform "x11" && params+=(--without-x --without-gtk)
    ./autogen.sh --prefix="$md_inst" "${params[@]}"
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
    
    mkUserDir "$md_conf_root/macintosh"

    addSystem 1 "$md_id" "macintosh" "$md_inst/bin/BasiliskII --rom $romdir/macintosh/mac.rom --disk $romdir/macintosh/disk.img --extfs $romdir/macintosh --config $md_conf_root/macintosh/basiliskii.cfg" "Apple Macintosh" ".txt"
}
