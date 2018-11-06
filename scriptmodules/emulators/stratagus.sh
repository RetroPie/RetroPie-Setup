#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="stratagus"
rp_module_desc="Stratagus - A strategy game engine to play Warcraft I or II, Starcraft, and some similar open-source games"
rp_module_help="Copy your Stratagus games to $romdir/stratagus"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Wargus/stratagus/master/COPYING"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function depends_stratagus() {
    getDepends libsdl1.2-dev libbz2-dev libogg-dev libvorbis-dev libtheora-dev libpng-dev liblua5.1-0-dev libtolua++5.1-dev libfluidsynth-dev libmikmod-dev
}

function sources_stratagus() {
    gitPullOrClone "$md_build" https://github.com/Wargus/stratagus.git
}

function build_stratagus() {
    mkdir build
    cd build
    cmake -DENABLE_STRIP=ON ..
    make
    md_ret_require="$md_build/build/stratagus"
}

function install_stratagus() {
    md_ret_files=(
        'build/stratagus'
        'COPYING'
    )
}

function configure_stratagus() {
    mkRomDir "stratagus"

    addEmulator 0 "$md_id" "stratagus" "$md_inst/stratagus -F -d %ROM%"
    addSystem "stratagus" "Stratagus Strategy Engine" ".wc1 .wc2 .sc .data"
}
