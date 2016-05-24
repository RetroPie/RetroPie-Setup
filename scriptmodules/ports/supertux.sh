#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
 
rp_module_id="supertux"
rp_module_desc="SuperTux 2d scrolling platform"
rp_module_section="opt"
rp_module_flags="!mali"
 
function install_bin_supertux() {
    aptInstall supertux
}
 
function configure_supertux() {
    addPort "$md_id" "supertux" "SuperTux" "supertux"
}