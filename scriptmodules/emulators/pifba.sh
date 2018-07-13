#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pifba"
rp_module_desc="FBA emulator PiFBA"
rp_module_help="ROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA roms."
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/pifba/master/FBAcapex_src/COPYING"
rp_module_section="main"
rp_module_flags="!x11 !mali !kms"

function depends_pifba() {
    getDepends libasound2-dev libsdl1.2-dev libraspberrypi-dev
}

function sources_pifba() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/pifba.git
}

function build_pifba() {
    mkdir ".obj"
    make clean
    make
    md_ret_require="$md_build/fba2x"
}

function install_pifba() {
    mkdir -p "$md_inst/"{roms,skin,preview}
    md_ret_files=(
        'fba2x'
        'fba2x.cfg.template'
        'capex.cfg.template'
        'zipname.fba'
        'rominfo.fba'
        'FBACache_windows.zip'
        'fba_029671_clrmame_dat.zip'
    )
}

function configure_pifba() {
    mkRomDir "arcade"
    mkRomDir "fba"
    mkRomDir "neogeo"

    mkUserDir "$md_conf_root/fba"

    local config
    for config in fba2x.cfg capex.cfg; do
        # move old config if it exists
        moveConfigFile "$md_inst/$config" "$md_conf_root/fba/$config"
        copyDefaultConfig "$config.template" "$md_conf_root/fba/$config"
    done

    local def=0
    isPlatform "rpi1" && def=1
    addEmulator 0 "$md_id" "arcade" "$md_inst/fba2x %ROM%"
    addEmulator $def "$md_id" "neogeo" "$md_inst/fba2x %ROM%"
    addEmulator $def "$md_id" "fba" "$md_inst/fba2x %ROM%"
    addSystem "arcade"
    addSystem "neogeo"
    addSystem "fba"
}
