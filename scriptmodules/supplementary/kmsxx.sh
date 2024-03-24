#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="kmsxx"
rp_module_desc="library and utilities for Linux kernel mode setting"
rp_module_licence="MPL2 https://raw.githubusercontent.com/cmitu/kmsxx/master/LICENSE"
rp_module_repo="git https://github.com/cmitu/kmsxx retropie"
rp_module_section="depends"
rp_module_flags=""

function depends_kmsxx() {
    getDepends meson ninja-build libdrm-dev libfmt-dev pkg-config
}

function sources_kmsxx() {
    gitPullOrClone
}

function build_kmsxx() {
    rm -fr build
    meson setup --prefix="$md_inst" -Dbuildtype=release -Ddefault_library=static -Domap=disabled -Dpykms=disabled -Dkmscube=false build
    ninja -C build

    md_ret_require="$md_build/build/utils/kmsprint-rp"
}

function install_kmsxx() {
    md_ret_files=(
        build/utils/kmsprint-rp
        build/utils/kmsprint
        build/utils/kmsview
        build/utils/kmsblank
        build/utils/fbtest
    )
}
