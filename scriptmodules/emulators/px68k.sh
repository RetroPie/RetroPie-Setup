#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="px68k"
rp_module_desc="SHARP X68000 Emulator"
rp_module_menus="4+"
rp_module_flags="!mali"

function depends_px68k() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev
}

function sources_px68k() {
    gitPullOrClone "$md_build" https://github.com/hissorii/px68k.git
}

function build_px68k() {
    make clean
    make MOPT="" CDEBUGFLAGS="$CFLAGS -DUSE_SDLGFX -DNO_MERCURY"
    md_ret_require="$md_build/px68k"
}

function install_px68k() {
    md_ret_files=(
        'px68k'
        'readme.txt'
    )
}

function configure_px68k() {
    mkRomDir "x68000"

    moveConfigDir "$home/.keropi" "$md_conf_root/x68000"

    local bios
    for bios in cgrom.dat plrom30.dat iplromco.dat iplrom.dat iplromxv.dat; do
        ln -sf "$biosdir/$bios" "$md_conf_root/x68000/$bios"
    done

    setDispmanx "$md_id" 0

    addSystem 1 "$md_id" "x68000" "$md_inst/px68k %ROM%" "X68000" ".dim"

    __INFMSGS+=("You need to copy the X68000 bios files plrom30.dat, iplromco.dat, iplrom.dat, iplromxv.dat, and the font file cgrom.dat to $romdir/BIOS. Use F12 to access the in emulator menu.")
}
