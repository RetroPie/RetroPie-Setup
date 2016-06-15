#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
 
rp_module_id="openttd"
rp_module_desc="Open Source Simulator Based On Transport Tycoon Deluxe"
rp_module_section="opt"
rp_module_flags="!mali"

function _update_hook_openttd() {
    # to show as installed in retropie-setup 4.x
    hasPackage openttd && mkdir -p "$md_inst"
}

function install_bin_openttd() {
    aptInstall openttd
}
 
function configure_openttd() {
    addPort "$md_id" "openttd" "OpenTTD" "openttd"
}