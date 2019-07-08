#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="neverball"
rp_module_desc="3D floor-tilting & miniature golf games"
rp_module_licence="GPL2 https://github.com/Neverball/neverball/blob/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="!mali gl4es"

function depends_neverball() {
    local depends=("libgl1-mesa-dev")

    getDepends "${depends[@]}"
}

function _update_hook_neverball() {
    # to show as installed in retropie-setup 4.x
    hasPackage neverball && hasPackage neverputt && mkdir -p "$md_inst"
}

function install_bin_neverball() {
    aptInstall neverball neverputt
}

function remove_neverball() {
    aptRemove neverball neverball-common neverball-data neverputt neverputt-data
}

function configure_neverball() {
    moveConfigDir "$home/.neverball" "$md_conf_root/neverball"

    addPort "$md_id" "neverball" "Neverball" "neverball"
    addPort "$md_id" "neverputt" "Neverputt" "neverputt"
}
