#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="nxengine"
rp_module_desc="Cave Story engine clone - NxEngine port for Raspberry Pi"
rp_module_help="The original Cave Story game files are automatically installed to $md_inst."
rp_module_section="opt"

function install_bin_nxengine() {
    wget -O cavestory.zip "http://www.sheasilverman.com/rpi/raspbian/installer/cavestory.zip"
    unzip -oj cavestory.zip -d "$md_inst"
    rm cavestory.zip
}

function configure_nxengine() {
    addPort "$md_id" "cavestory" "Cave Story" "$md_inst/nx"
}
