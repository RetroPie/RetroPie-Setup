#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bluemsx"
rp_module_desc="MSX/MSX2/Colecovision emu - blueMSX port for libretro"
rp_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx\nCopy your Colecovision games to $romdir/coleco\n\nlr-bluemsx requires the BIOS files from the full standalone package of BlueMSX to be copied to '$biosdir/Machines' folder.\nColecovision BIOS needs to be copied to '$biosdir/Machines/COL - ColecoVision\coleco.rom'"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/blueMSX-libretro/master/license.txt"
rp_module_section="opt"

function sources_lr-bluemsx() {
    gitPullOrClone "$md_build" https://github.com/libretro/blueMSX-libretro.git
}

function build_lr-bluemsx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/bluemsx_libretro.so"
}

function install_lr-bluemsx() {
    md_ret_files=(
        'bluemsx_libretro.so'
        'README.md'
        'system/bluemsx/Databases'
        'system/bluemsx/Machines'
    )
}

function install_bin_lr-bluemsx() {
    downloadAndExtract "http://github.com/Retro-Arena/xu4-bins/raw/master/lr-bluemsx.tar.gz" "$md_inst" 1
}

function configure_lr-bluemsx() {
    local system
    for system in msx msx2 coleco; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 1 "$md_id" "$system" "$md_inst/bluemsx_libretro.so"
        addSystem "$system"
    done

    # force colecovision system
    local core_config="$md_conf_root/coleco/retroarch-core-options.cfg"
    iniConfig " = " '"' "$md_conf_root/coleco/retroarch.cfg"
    iniSet "core_options_path" "$core_config"
    iniSet "bluemsx_msxtype" "ColecoVision" "$core_config"
    chown $user:$user "$core_config"

    cp -rv "$md_inst/"{Databases,Machines} "$biosdir/"
    chown -R $user:$user "$biosdir/"{Databases,Machines}
}
