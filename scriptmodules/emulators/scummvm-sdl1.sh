#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="scummvm-sdl1"
rp_module_desc="ScummVM - built with legacy SDL1 support."
rp_module_help="Copy your ScummVM games to $romdir/scummvm"
rp_module_licence="GPL2 https://raw.githubusercontent.com/scummvm/scummvm/master/COPYING"
rp_module_section="opt"
rp_module_flags="dispmanx !mali !x11 !kms"

function depends_scummvm-sdl1() {
    depends_scummvm
}

function sources_scummvm-sdl1() {
    # sources_scummvm() expects $md_data to be ../scummvm
    # the following only modifies $md_data for the function call
    md_data="$md_data/../scummvm" sources_scummvm
    if isPlatform "rpi"; then
        applyPatch "$md_data/01_rpi_sdl1.diff"
    fi
}

function build_scummvm-sdl1() {
    build_scummvm
}

function install_scummvm-sdl1() {
    install_scummvm
}

function configure_scummvm-sdl1() {
    configure_scummvm
}
