#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="osmose"
rp_module_desc="Gamegear emulator Osmose"
rp_module_help="ROM Extensions: .bin .gg .sms .zip\nCopy your Game Gear roms to $romdir/gamegear\n\nMasterSystem roms to $romdir/mastersystem"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/osmose-rpi/master/license.txt"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function depends_osmose() {
    getDepends libsdl1.2-dev
}

function sources_osmose() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/osmose-rpi.git
}

function build_osmose() {
    make clean
    # not safe for building in parallel
    make -j1
    md_ret_require="$md_build/osmose"
}

function install_osmose() {
    md_ret_files=(
        'changes.txt'
        'license.txt'
        'osmose'
    )
}

function configure_osmose() {
    mkRomDir "gamegear"
    mkRomDir "mastersystem"

    addEmulator 0 "$md_id" "gamegear" "$md_inst/osmose %ROM% -tv -fs"
    addEmulator 0 "$md_id" "mastersystem" "$md_inst/osmose %ROM% -tv -fs"
    addSystem "gamegear"
    addSystem "mastersystem"
}
