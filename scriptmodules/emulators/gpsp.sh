#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"
rp_module_flags=""

function depends_gpsp() {
    getDepends libsdl1.2-dev
}

function sources_gpsp() {
    gitPullOrClone "$md_build" git://github.com/gizmo98/gpsp.git
    sed -i 's/-mfpu=vfp -mfloat-abi=hard -march=armv6j//' raspberrypi/Makefile
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

    mkUserDir "$configdir/gba"

    # symlink the rom so so it can be installed with the other bios files
    ln -sf "$biosdir/gba_bios.bin" "$md_inst/gba_bios.bin"

    # move old config
    if [[ -f "gpsp.cfg" && ! -h "gpsp.cfg" ]]; then
        mv "gpsp.cfg" "$configdir/gba/gpsp.cfg"
    fi

    ln -sf "$configdir/gba/gpsp.cfg" "$md_inst/gpsp.cfg"


    addSystem 0 "$md_id" "gba" "$md_inst/gpsp %ROM%"
}
