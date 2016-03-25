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
rp_module_flags="!mali"

function depends_alephone() {
    getDepends libboost-all-dev libsdl1.2-dev libsdl-net1.2-dev libsdl-image1.2-dev libsdl-ttf2.0-dev libspeexdsp-dev libzzip-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev autoconf automake
}

function sources_alephone() {
    gitPullOrClone "$md_build" "https://github.com/Aleph-One-Marathon/alephone.git" "release-20150620"
}

function build_alephone() {
    params=(--prefix="$md_inst")
    isPlatform "arm" && params+=(--with-boost-libdir=/usr/lib/arm-linux-gnueabihf)
    ./autogen.sh
    ./configure "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/Source_Files/alephone"
}

function install_alephone() {
    make install
}

function configure_alephone() {
    addPort "$md_id" "marathon" "Aleph One Engine - Marathon" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon/'"
    addPort "$md_id" "marathon2" "Aleph One Engine - Marathon 2" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon 2/'"
    addPort "$md_id" "marathoninfinity" "Aleph One Engine - Marathon Infinity" "'$md_inst/bin/alephone' '$romdir/ports/$md_id/Marathon Infinity/'"

    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.alephone" "$configDir/alephone"

    local release_url="https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20150620"
    if [[ ! -f "$romdir/ports/$md_id/Marathon/Shapes.shps" ]]; then
        wget "$release_url/Marathon-20150620-Data.zip"
        unzip Marathon-20150620-Data.zip -d "$romdir/ports/$md_id"
        rm Marathon-20150620-Data.zip
    fi

    if [[ ! -f "$romdir/ports/$md_id/Marathon 2/Shapes.shpA" ]]; then
        wget "$release_url/Marathon2-20150620-Data.zip"
        unzip Marathon2-20150620-Data.zip -d "$romdir/ports/$md_id"
        rm Marathon2-20150620-Data.zip
    fi

    if [[ ! -f "$romdir/ports/$md_id/Marathon Infinity/Shapes.shpA" ]]; then
        wget https://github.com/Aleph-One-Marathon/alephone/releases/download/release-20150620/MarathonInfinity-20150620-Data.zip
        unzip MarathonInfinity-20150620-Data.zip -d "$romdir/ports/$md_id"
        rm MarathonInfinity-20150620-Data.zip
    fi

    chown -R $user:$user "$romdir/ports/$md_id"

    if isPlatform "rpi"; then
        __INFMSGS+=("To get the games running, make sure to set each game to use the software renderer and disable the enhanced HUD from the Plugins menu. For Marathon 1, disable both HUDs from the Plugins menu, start a game, quit back to the title screen and enable Enhanced HUD and it will work and properly.")
    fi
}
