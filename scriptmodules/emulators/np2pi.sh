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
rp_module_help="ROM Extensions: .d88 .d98 .88d .98d .fdi .xdf .hdm .dup .2hd .tfd .hdi .thd .nhd .hdd .D88 .D98 .88D .98D .FDI .XDF .HDM .DUP .2HD .TFD .HDI .THD .NHD .HDD"
rp_module_section="exp"

function depends_np2pi() {
    local depends=(libasound2-dev libsdl2-ttf-dev ttf-sazanami-gothic)
    getDepends "${depends[@]}"
}

function sources_np2pi() {
    git clone -b np2pi https://github.com/irori/SDL12-kms-dispmanx.git
    cd SDL12-kms-dispmanx
    git checkout d96f55822880ac26eecc8684ca44194b7220b1de
    cd ..
    git clone https://github.com/eagle0wl/np2pi.git
    cd np2pi 
    git checkout dabcc56e1fbf5f78b18a490810e93732681f36c7
}

function build_np2pi() {
    cd SDL12-kms-dispmanx
    ./MAC_ConfigureDISPMANX.sh
    make -j 1 ; sudo make install 
    cd ..
    cd np2pi/sdl
    make -j 1 -f makefile.rpi
}

function install_np2pi() {
    sudo mkdir -p $md_inst
    sudo cp np2pi/bin/np2 $md_inst
    sudo ln -s /usr/share/fonts/truetype/sazanami/sazanami-gothic.ttf $md_inst/default.ttf
}

function configure_np2pi() {
    mkRomDir "pc98"
    mkUserDir "$md_conf_root/np2pi"
    mkUserDir "$biosdir/np2pi"
    local bios
    for bios in 2608_bd.wav 2608_hh.wav 2608_rim.wav 2608_sd.wav 2608_tom.wav 2608_top.wav bios.rom FONT.ROM sound.rom; do
        ln -sf "$biosdir/np2pi/$bios" "$md_inst/$bios"
    done
    sudo touch $md_conf_root/np2pi/np2.cfg
    sudo chmod 666 $md_conf_root/np2pi/np2.cfg
    sudo ln -s $md_conf_root/np2pi/np2.cfg "$md_inst/np2.cfg"
    setDispmanx "$md_id" 0
    addEmulator 1 "np2pi" "np2pi" "$md_inst/np2pi %ROM%"
    addSystem "np2pi"
}
