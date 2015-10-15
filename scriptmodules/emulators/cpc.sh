#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cpc"
rp_module_desc="Amstrad CPC emulator"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function sources_cpc() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/cpc4rpi-1.1_src.tar.gz | tar -xvz --strip-components=1
    sed -i 's|-lGLESv2 -lEGL|-lSDL|g' makefile
    sed -i 's|-lts||g' makefile
    sed -i 's|/root/Raspbian/Libs/libSDL.a /root/Raspbian/Libs/libnofun.a||g' makefile
    sed -i 's|= $(GFLAGS) -mcpu=arm1176jzf-s -march=armv6zk -O2 -funroll-loops -ffast-math -fomit-frame-pointer -fno-strength-reduce -finline-functions -s|+= $(GFLAGS) -ffast-math -s|g' makefile
}

function build_cpc() {
    make clean

    make RELEASE=TRUE
    md_ret_require="$md_build/cpc4rpi"
}

function install_cpc() {
    cp -R "$md_build/"{cpc4rpi,*.txt} "$md_inst/"
    md_ret_require="$md_inst/cpc4rpi"
}

function configure_cpc() {
    mkRomDir "amstradcpc"

    addSystem 1 "$md_id" "amstradcpc" "$md_inst/cpc4rpi %ROM%"
}
