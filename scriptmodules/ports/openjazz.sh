#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openjazz"
rp_module_desc="OpenJazz - an enhanced Jazz Jackrabbit source port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/AlisterT/openjazz/master/COPYING"
rp_module_help="For registered version, replace the shareware files by adding your full version game files to $romdir/ports/jazz/."
rp_module_section="exp"
rp_module_flags=""

function depends_openjazz() {
    getDepends cmake libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev timidity freepats
}

function sources_openjazz() {
    gitPullOrClone "$md_build" https://github.com/AlisterT/openjazz.git
}

function build_openjazz() {
    cd "$md_build"
    make
    md_ret_require="$md_build/"
}

function install_openjazz() {
    md_ret_files=(
       'OpenJazz'
       'openjazz.000'
    )
}

function game_data_openjazz() {
    if [[ ! -f "$romdir/ports/jazz/JAZZ.EXE" ]]; then
        downloadAndExtract "https://image.dosgamesarchive.com/games/jazz.zip" "$romdir/ports/jazz"
        chown -R $user:$user "$romdir/ports/jazz"
    fi
}

function configure_openjazz() {
    addPort "$md_id" "openjazz" "Jazz Jackrabbit" "$md_inst/OpenJazz HOMEDIR $romdir/ports/jazz"

    mkRomDir "ports/jazz"

    moveConfigDir "$home/.openjazz" "$md_conf_root/openjazz"

    moveConfigFile "$home/openjazz.cfg" "$md_conf_root/openjazz/openjazz.cfg"

    [[ "$md_mode" == "install" ]] && game_data_openjazz
}
