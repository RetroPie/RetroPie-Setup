#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ppsspp-1.5.4"
rp_module_desc="PlayStation Portable emulator PPSSPP v1.5.4"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp.git v1.5.4"
rp_module_section="opt"
rp_module_flags="!all videocore"

function depends_ppsspp-1.5.4() {
    depends_ppsspp
}

function sources_ppsspp-1.5.4() {
    sources_ppsspp "v1.5.4"
}

function build_ppsspp-1.5.4() {
    build_ppsspp
}

function install_ppsspp-1.5.4() {
    install_ppsspp
}

function configure_ppsspp-1.5.4() {
    configure_ppsspp
}
