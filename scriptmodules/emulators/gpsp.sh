#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"
rp_module_flags="!x86 !mali"

function depends_gpsp() {
    getDepends libsdl1.2-dev libraspberrypi-dev
}

function sources_gpsp() {
    gitPullOrClone "$md_build" https://github.com/gizmo98/gpsp.git
}

function build_gpsp() {
    cd raspberrypi
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/raspberrypi/gpsp"
}

function install_gpsp() {
    md_ret_files=(
        'COPYING.DOC'
        'game_config.txt'
        'readme.txt'
        'raspberrypi/gpsp'
    )
}

function configure_gpsp() {
    mkRomDir "gba"
    chown $user:$user -R "$md_inst"

    mkUserDir "$md_conf_root/gba"

    # symlink the rom so so it can be installed with the other bios files
    ln -sf "$biosdir/gba_bios.bin" "$md_inst/gba_bios.bin"

    # move old config
    moveConfigFile "gpsp.cfg" "$md_conf_root/gba/gpsp.cfg"

    addSystem 0 "$md_id" "gba" "$md_inst/gpsp %ROM%"
}
