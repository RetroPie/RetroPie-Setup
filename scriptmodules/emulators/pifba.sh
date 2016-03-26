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
rp_module_menus="2+"
rp_module_flags="!x86 !mali"

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
        # move old config
        moveConfigFile "$md_inst/$config" "$md_conf_root/fba/$config"

        # if the user doesn't already have a config, we will copy the default.
        if [[ ! -f "$md_conf_root/fba/$config" ]]; then
            cp "$config.template" "$md_conf_root/fba/$config"
        fi
        chown $user:$user "$md_conf_root/fba/$config"
    done

    local def=0
    isPlatform "rpi1" && def=1
    addSystem 0 "$md_id" "arcade" "$md_inst/fba2x %ROM%"
    addSystem $def "$md_id" "neogeo" "$md_inst/fba2x %ROM%"
    addSystem $def "$md_id" "fba arcade" "$md_inst/fba2x %ROM%"
}
