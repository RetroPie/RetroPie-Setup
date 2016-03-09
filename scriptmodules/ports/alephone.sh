#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="alephone"
rp_module_desc="AlephOne - Marathon Engine"
rp_module_menus="4+"
rp_module_flags="!x11 !mali"

function depends_alephone() {
    getDepends libboost-all-dev libsdl1.2-dev libsdl-net1.2-dev libsdl-image1.2-dev libsdl-ttf2.0-dev libspeexdsp-dev libzzip-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev
}

function sources_alephone() {
    wget -O- -q https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20150620/AlephOne-20150620.tar.bz2 | tar -xvj --strip-components=1
}

function build_alephone() {
    ./configure --prefix="$md_inst" --with-boost-libdir=/usr/lib/arm-linux-gnueabihf
    make clean
    make
}

function install_alephone() {
    make install
}

function configure_alephone() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id/"
    moveConfigDir "$home/.alephone" "$configDir/alephone"

    if [[ ! -f "$romdir/ports/$md_id/Marathon/Shapes.shps" ]]; then
        wget https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20150620/Marathon-20150620-Data.zip
        unzip Marathon-20150620-Data.zip -d "$__tmpdir/"
        mv "$__tmpdir/Marathon" "$romdir/ports/$md_id/"
        rm -rf "$__tmpdir/Marathon"
        rm Marathon-20150620-Data.zip
    fi

    if [[ ! -f "$romdir/ports/$md_id/Marathon 2/Shapes.shpA" ]]; then
        wget https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20150620/Marathon2-20150620-Data.zip
        unzip Marathon2-20150620-Data.zip -d "$__tmpdir/"
        mv "$__tmpdir/Marathon 2" "$romdir/ports/$md_id/"
        rm -rf "$__tmpdir/Marathon 2"
        rm Marathon2-20150620-Data.zip
    fi

    if [[ ! -f "$romdir/ports/$md_id/Marathon Infinity/Shapes.shpA" ]]; then
        wget https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20150620/MarathonInfinity-20150620-Data.zip
        unzip MarathonInfinity-20150620-Data.zip -d "$__tmpdir/"
        mv "$__tmpdir/Marathon Infinity" "$romdir/ports/$md_id"
        rm -rf "$__tmpdir/Marathon Infinity"
        rm MarathonInfinity-20150620-Data.zip
    fi

    addPort "$md_id" "marathon" "Aleph One Engine - Marathon" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon/'"
    addPort "$md_id" "marathon2" "Aleph One Engine - Marathon 2" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon 2/'"
    addPort "$md_id" "marathoninfinity" "Aleph One Engine - Marathon Infinity" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon Infinity/'"
    __INFMSGS+=("To get the games running, make sure to set each game to use the software renderer and disable the enhanced HUD from the Plugins menu. For Marathon 1, disable both HUDs from the Plugins menu, start a game, quit back to the title screen and enable Enhanced HUD and it will work and properly.")

}
