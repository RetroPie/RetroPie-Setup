#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="stella"
rp_module_desc="Atari2600 emulator STELLA"
rp_module_help="ROM Extensions: .a26 .bin .rom .zip .gz\n\nCopy your Atari 2600 roms to $romdir/atari2600"
rp_module_section="opt"
rp_module_flags="dispmanx !mali"

function _update_hook_stella() {
    # to show as installed in retropie-setup 4.x
    hasPackage stella && mkdir -p "$md_inst"
}

function install_bin_stella() {
    aptInstall stella
}

function remove_stella() {
    aptRemove stella
}

function configure_stella() {
    mkRomDir "atari2600"

    if ! isPlatform "x11"; then
        setDispmanx "$md_id" 1
    fi

    delSystem "$md_id" "atari2600-stella"
    addSystem 0 "$md_id" "atari2600" "stella -maxres 320x240 %ROM%"
}
