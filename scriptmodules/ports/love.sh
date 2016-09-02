#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="love"
rp_module_desc="Love - 2d Game Engine"
rp_module_help="Copy your Love roms to $romdir/love"
rp_module_section="opt"

function depends_love() {
    local depends=(mercurial autotools-dev automake libtool pkg-config libdevil-dev libfreetype6-dev libluajit-5.1-dev libphysfs-dev libsdl2-dev libopenal-dev libogg-dev libtheora-dev libvorbis-dev libflac-dev libflac++-dev libmodplug-dev libmpg123-dev libmng-dev)

    if [[ "$__raspbian_ver" -lt "8" ]]; then
        depends+=(libjpeg8-dev )
    else
        depends+=(libjpeg-dev)
    fi

    getDepends "${depends[@]}"
}

function sources_love() {
    hg clone https://bitbucket.org/rude/love "$md_build"
}

function build_love() {
    ./platform/unix/automagic
    local params=(--prefix="$md_inst")

    # workaround for https://gcc.gnu.org/bugzilla/show_bug.cgi?id=65612 on gcc 5.x+
    if isPlatform "x86"; then
        CXXFLAGS+=" -lgcc_s -lgcc" ./configure "${params[@]}"
    else
        ./configure "${params[@]}"
    fi

    make clean
    make
    md_ret_require="$md_build/src/love"
}

function install_love() {
    make install
}

function game_data_love() {
    # get Mari0 10.0 (freeware game data)
    if [[ ! -f "$romdir/love/mari0.love" ]]; then
        wget "https://github.com/radgeRayden/future-mari0/releases/download/v0.2/mari0.love" -O "$romdir/love/mari0.love"
        chown $user:$user "$romdir/love/mari0.love"
    fi
}

function configure_love() {
    setConfigRoot ""

    mkRomDir "love"

    addSystem 1 "$md_id" "love" "$md_inst/bin/love %ROM%" "Love" ".love"

    [[ "$md_mode" == "install" ]] && game_data_love
}
