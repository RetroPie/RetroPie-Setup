#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xrick"
rp_module_desc="xrick - Port of Rick Dangerous"
rp_module_licence="GPL https://raw.githubusercontent.com/HerbFargus/xrick/master/README"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function depends_xrick() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev zlib1g
}

function sources_xrick() {
    gitPullOrClone "$md_build" https://github.com/HerbFargus/xrick.git
}

function build_xrick() {
    make
    md_ret_require="$md_build/xrick"
}

function install_xrick() {
    md_ret_files=(
        'data.zip'
        'xrick'
    )
}

function configure_xrick() {
    addPort "$md_id" "xrick" "XRick" "pushd $md_inst; $md_inst/xrick -fullscreen; popd"
}
