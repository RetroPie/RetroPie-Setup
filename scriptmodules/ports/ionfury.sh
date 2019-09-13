#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ionfury"
rp_module_desc="Ion Fury - commercial FPS game based on eduke32 source port"
rp_module_licence="GPL2 http://svn.eduke32.com/eduke32/package/common/gpl-2.0.txt"
rp_module_section="exp"

function depends_ionfury() {
    depends_eduke32
}

function sources_ionfury() {
    # patches are also shared with eduke32, so avoid duplication
    md_data="$(dirname $md_data)/eduke32" sources_eduke32
}

function build_ionfury() {
    build_eduke32
}

function install_ionfury() {
    install_eduke32
}

function configure_ionfury() {
    configure_eduke32
}
