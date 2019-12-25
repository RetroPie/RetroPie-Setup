#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="simcoupe"
rp_module_desc="SimCoupe SAM Coupe emulator"
rp_module_help="ROM Extensions: .dsk .mgt .sbt .sad\n\nCopy your SAM Coupe games to $romdir/samcoupe."
rp_module_licence="GPL2 https://raw.githubusercontent.com/simonowen/simcoupe/master/License.txt"
rp_module_section="opt"
rp_module_flags=""

function depends_simcoupe() {
    getDepends cmake libsdl2-dev zlib1g-dev libbz2-dev libspectrum-dev
}

function sources_simcoupe() {
    gitPullOrClone "$md_build" https://github.com/simonowen/simcoupe.git
}

function build_simcoupe() {
    cmake -DCMAKE_INSTALL_PREFIX="$md_inst" .
    make clean
    make
    md_ret_require="$md_build/simcoupe"
}

function install_simcoupe() {
    make install
}

function configure_simcoupe() {
    mkRomDir "samcoupe"
    moveConfigDir "$home/.simcoupe" "$md_conf_root/$md_id"

    addEmulator 1 "$md_id" "samcoupe" "pushd $md_inst; $md_inst/bin/simcoupe autoboot -disk1 %ROM% -fullscreen; popd"
    addSystem "samcoupe"
}
