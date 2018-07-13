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
rp_module_help="You need to copy a X68000 bios file (iplrom30.dat, iplromco.dat, iplrom.dat, or iplromxv.dat), and the font file (cgrom.dat or cgrom.tmp) to $romdir/BIOS/keropi. Use F12 to access the in emulator menu."
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_px68k() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev
}

function sources_px68k() {
    gitPullOrClone "$md_build" https://github.com/hissorii/px68k.git
}

function build_px68k() {
    make clean
    make MOPT="" CDEBUGFLAGS="$CFLAGS -O2 -DUSE_SDLGFX -DNO_MERCURY"
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
    mkUserDir "$biosdir/keropi"

    local bios
    for bios in cgrom.dat iplrom30.dat iplromco.dat iplrom.dat iplromxv.dat; do
        if [[ -f "$biosdir/$bios" ]]; then
            mv "$biosdir/$bios" "$biosdir/keropi/$bios"
        fi
        ln -sf "$biosdir/keropi/$bios" "$md_conf_root/x68000/$bios"
    done

    setDispmanx "$md_id" 0

    addEmulator 1 "$md_id" "x68000" "$md_inst/px68k %ROM%"
    addSystem "x68000"
}
