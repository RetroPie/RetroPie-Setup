#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="amiberry"
rp_module_desc="Amiga emulator with JIT support (forked from uae4arm)"
rp_module_help="ROM Extension: .adf\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/midwan/amiberry/master/COPYING"
rp_module_section="opt"
rp_module_flags="!x86 !mali !kms"

function depends_amiberry() {
    depends_uae4arm
}

function sources_amiberry() {
    gitPullOrClone "$md_build" https://github.com/midwan/amiberry/
}

function build_amiberry() {
    make clean
    CXXFLAGS="" make PLATFORM="$__platform"
    md_ret_require="$md_build/amiberry"
}

function install_amiberry() {
    md_ret_files=(
        'data'
        'amiberry'
    )
}

function configure_amiberry() {
    configure_uae4arm
}
