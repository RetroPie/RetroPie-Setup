#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="np2pi"
rp_module_desc="NEC PC-9801 emulator"
rp_module_help="ROM Extensions: .d88 .d98 .88d .98d .fdi .xdf .hdm .dup .2hd .tfd .hdi .thd .nhd .hdd"
rp_module_section="exp"
rp_module_flags="!x11 !mali"

function depends_np2pi() {
    local depends=(libsdl1.2-dev libasound2-dev libsdl-ttf2.0-dev ttf-sazanami-gothic)
    getDepends "${depends[@]}"
}

function sources_np2pi() {
    git clone https://github.com/eagle0wl/np2pi.git
}

function build_np2pi() {
    cd np2pi/sdl
    make -j 1 -f makefile.rpi
}

function install_np2pi() {
    md_ret_files=('np2pi/bin/np2')
}

function configure_np2pi() {
    ln -s /usr/share/fonts/truetype/sazanami/sazanami-gothic.ttf "$md_inst/default.ttf"
    mkRomDir "pc98"
    mkUserDir "$biosdir/np2pi"
    local bios
    for bios in 2608_bd.wav 2608_hh.wav 2608_rim.wav 2608_sd.wav 2608_tom.wav 2608_top.wav bios.rom FONT.ROM sound.rom; do
        ln -sf "$biosdir/np2pi/$bios" "$md_inst/$bios"
    done
    mkUserDir "$md_conf_root/np2pi"
    touch "$md_conf_root/np2pi/np2.cfg"
    chown $user:$user "$md_conf_root/np2pi/np2.cfg"
    moveConfigFile "$md_conf_root/np2pi/np2.cfg" "$md_inst/np2.cfg"
    setDispmanx "$md_id" 0
    addEmulator 1 "np2pi" "np2pi" "$md_inst/np2pi %ROM%"
    addSystem "np2pi"
}
