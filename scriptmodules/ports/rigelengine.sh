#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="rigelengine"
rp_module_desc="RigelEngine - Duke Nukem 2 source port"
rp_module_help="Copy your game to roms/ports/duke2 folder"
rp_module_licence="GPL2 https://github.com/lethal-guitar/RigelEngine/blob/master/LICENSE.md"
rp_module_repo="git https://github.com/lethal-guitar/RigelEngine.git v0.9.1"
rp_module_section="exp"
rp_module_flags="noinstclean"

function depends_rigelengine() {
    getDepends cmake libsdl2-dev libsdl2-mixer-dev
}

function sources_rigelengine() {
    gitPullOrClone
}

function build_rigelengine() {
    mkdir $md_build/build
    cd $md_build/build
    cmake .. -DUSE_GL_ES=ON -DCMAKE_BUILD_TYPE=Release -DWARNINGS_AS_ERRORS=OFF

    make

    md_ret_require="$md_build/build/src/RigelEngine"
}

function install_rigelengine() {
    md_ret_files=(
        build/src/RigelEngine
    )
}

function game_data_rigelengine() {
    if [[ ! -f "$romdir/ports/duke2/NUKEM2.EXE" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/duke2.zip" "$romdir/ports/duke2/"
    #mv "$romdir/ports/duke2/Duke2"* "$romdir/ports/duke2/"
    chown -R $user:$user "$romdir/ports/duke2"
    fi
}

function configure_rigelengine() {
    addPort "$md_id" "rigelengine" "RigelEngine - Duke Nukem 2 source port" "$md_inst/RigelEngine /home/pi/RetroPie/roms/ports/duke2"
    mkRomDir "ports/duke2"
    [[ "$md_mode" == "install" ]] && game_data_rigelengine
}
