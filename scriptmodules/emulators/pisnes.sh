#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pisnes"
rp_module_desc="SNES emulator PiSNES"
rp_module_menus="2+"

function depends_pisnes() {
    getDepends libasound2-dev libsdl1.2-dev libraspberrypi-dev
}

function sources_pisnes() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/pisnes.git
}

function build_pisnes() {
    make clean
    make
    md_ret_require="$md_build/snes9x"
}

function install_pisnes() {
    md_ret_files=(
        'changes.txt'
        'hardware.txt'
        'problems.txt'
        'readme_snes9x.txt'
        'readme.txt'
        'roms'
        'skins'
        'snes9x'
        'snes9x.cfg'
        'snes9x.gui'
    )
}

function configure_pisnes() {
    mkRomDir "snes"

    setDispmanx "$md_id" 1

    delSystem "$md_id" "snes-pisnes"
    addSystem 0 "$md_id" "snes" "$md_inst/snes9x %ROM%"
}
