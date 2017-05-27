#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
 
rp_module_id="labbayedesmorts"
rp_module_desc="L'Abbaye Des Morts"
rp_module_section="opt"
rp_module_flags="!mali !x86"


function depends_labbayedesmorts() {
   getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-ttf2.0-dev libsdl-gfx1.2-dev

}

function sources_labbayedesmorts() {
    gitPullOrClone "$md_build" https://github.com/RetroPieNerd/LAbbayeDesMortsRPI.git
}

function build_labbayedesmorts() {
    ./configure --prefix="$md_inst"
    make clean
    make
}

function install_labbayedesmorts() {
    make install
}
 
function configure_labbayedesmorts() {
    addPort "$md_id" "labbayedesmorts" "L'Abbaye Des Morts" "$md_id/abbaye"
}
