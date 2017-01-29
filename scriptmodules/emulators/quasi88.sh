#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="quasi88"
rp_module_desc="NEC PC-8801 emulator"
rp_module_help="ROM Extensions: .d88 .88d .cmt .t88."
rp_module_section="exp"

function depends_quasi88() {
    getDepends libsdl1.2-dev
}

function sources_quasi88() {
    wget -q -O- "http://www.eonet.ne.jp/~showtime/quasi88/release/quasi88-0.6.4.tgz" | tar -xvz --strip-components=1
    applyPatch "$md_data/01_Makefile.diff"
}

function build_quasi88() {
    make clean
    make -j 1
}

function install_quasi88() {
    make install
}

function configure_quasi88() {
    mkRomDir "pc88"
    moveConfigDir "$home/.quasi88" "$md_conf_root/pc-8801/quasi88"
    setDispmanx "$md_id" 0
    addEmulator 1 "quasi88" "quasi88" "$md_inst/bin/quasi88.sdl -f6 IMAGE-NEXT1 -f7 IMAGE-NEXT2 -f8 NOWAI -f9 ROMAJI -f10 NUMLOCK %ROM%"
    addSystem "quasi88"
}
