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
rp_module_help="ROM Extensions: .d88 .d98 .88d .98d .fdi .xdf .hdm .dup .2hd .tfd .hdi .thd .nhd .hdd\n\nCopy your pc98 games to to $romdir/pc88\n\nCopy bios files 2608_bd.wav, 2608_hh.wav, 2608_rim.wav, 2608_sd.wav, 2608_tom.wav 2608_top.wav, bios.rom, FONT.ROM and sound.rom to $biosdir/pc98"
rp_module_section="exp"
rp_module_flags="dispmanx !x86 !mali !kms"

function depends_np2pi() {
    getDepends libsdl1.2-dev libasound2-dev libsdl-ttf2.0-dev fonts-takao-gothic
}

function sources_np2pi() {
    gitPullOrClone "$md_build" https://github.com/eagle0wl/np2pi.git
}

function build_np2pi() {
    cd sdl
    make -j 1 -f makefile.rpi
}

function install_np2pi() {
    md_ret_files=(
        'bin/np2'
    )
}

function configure_np2pi() {
    mkRomDir "pc98"

    mkUserDir "$md_conf_root/pc98"

    # we launch from $md_conf_root/pc98 as emulator wants to create files in
    # the current directory (eg font.tmp).

    # symlink bios files
    mkUserDir "$biosdir/pc98"
    local bios
    for bios in 2608_bd.wav 2608_hh.wav 2608_rim.wav 2608_sd.wav 2608_tom.wav 2608_top.wav bios.rom FONT.ROM sound.rom; do
        ln -sf "$biosdir/pc98/$bios" "$md_conf_root/pc98/$bios"
    done

    # symlink font
    ln -sf /usr/share/fonts/truetype/takao-gothic/TakaoGothic.ttf "$md_conf_root/pc98/default.ttf"

    addEmulator 1 "$md_id" "pc98" "pushd $md_conf_root/pc98; $md_inst/np2 %ROM%; popd"
    addSystem "pc98"
}
