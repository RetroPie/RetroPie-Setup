#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="hexen2"
rp_module_desc="Hexen II - Hammer of Thyrion source port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/svn2github/uhexen2/master/docs/COPYING"
rp_module_help="For registered version, please add your full version PAK files to $romdir/ports/hexen2/data1/ to play. These files for the registered version are required: pak0.pak, pak1.pak and strings.txt. The registered pak files must be patched to 1.11 for Hammer of Thyrion."
rp_module_section="exp"
rp_module_flags=""

function depends_hexen2() {
    getDepends cmake libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev timidity freepats
}

function sources_hexen2() {
    gitPullOrClone "$md_build" https://github.com/svn2github/uhexen2.git
}

function build_hexen2() {
    cd "$md_build/engine/hexen2"
    ./build_all.sh
    md_ret_require="$md_build/engine/hexen2/hexen2"
}

function install_hexen2() {
    md_ret_files=(
       'engine/hexen2/hexen2'
    )
}

function game_data_hexen2() {
    if [[ ! -f "$romdir/ports/hexen2/data1/pak0.pak" ]]; then
        downloadAndExtract "https://netix.dl.sourceforge.net/project/uhexen2/Hexen2Demo-Nov.1997/hexen2demo_nov1997-linux-i586.tgz" "$romdir/ports/hexen2" --strip-components 1 "hexen2demo_nov1997/data1"
        chown -R $user:$user "$romdir/ports/hexen2/data1"
    fi
}

function configure_hexen2() {
    addPort "$md_id" "hexen2" "Hexen II" "$md_inst/hexen2"

    mkRomDir "ports/hexen2"

    moveConfigDir "$home/.hexen2" "$romdir/ports/hexen2"

    [[ "$md_mode" == "install" ]] && game_data_hexen2
}
