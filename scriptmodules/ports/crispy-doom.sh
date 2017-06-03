#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="crispy-doom"
rp_module_desc="Crispy Doom - Enhanced port of the official DOOM source"
rp_module_menus="4+"
rp_module_flags="!mali !x86"

function depends_crispy-doom() {
    getDepends libsdl1.2-dev libsdl-net1.2-dev libsdl-mixer1.2-dev python-imaging automake autoconf
}

function sources_crispy-doom() {
    gitPullOrClone "$md_build" https://github.com/fabiangreffrath/crispy-doom.git
}

function build_crispy-doom() {
    ./autogen.sh
    ./configure --prefix="$md_inst"
    make
    md_ret_require="$md_build/src/crispy-doom"
}

function install_crispy-doom() {
    md_ret_files=(
        'src/crispy-doom'
    )
}

function configure_crispy-doom() {
    mkRomDir "ports"
    mkRomDir "ports/doom"

    mkUserDir "$home/.config"
    moveConfigDir "$home/.crispy-doom" "$configdir/crispy-doom"

    # download doom 1 shareware
    if [[ ! -f "$romdir/ports/doom/doom1.wad" ]]; then
        wget "$__archive_url/doom1.wad" -O "$romdir/ports/doom/doom1.wad"
    fi

    chown $user:$user "$romdir/ports/doom/doom1.wad"
    addPort "$md_id" "crispy-doom" "Crispy Doom" "$md_inst/crispy-doom -iwad $romdir/ports/doom/doom1.wad"
}
