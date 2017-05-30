#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mayhem2"
rp_module_desc="Mayhem 2"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_mayhem2() {
    getDepends libdumb1 libvorbisfile3 libopenal1
}

function install_bin_mayhem2() {
    gitPullOrClone "$md_inst" https://github.com/martinohanlon/mayhem-pi
}

function configure_mayhem2() {
    addPort "$md_id" "mayhem2" "Mayhem 2" "pushd $md_inst; $md_inst/mayhem2-pi; popd"

    chmod +x "$md_inst/mayhem2-pi"
}
