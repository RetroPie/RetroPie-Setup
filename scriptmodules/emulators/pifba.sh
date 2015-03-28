#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="pifba"
rp_module_desc="FBA emulator PiFBA"
rp_module_menus="2+"

function depends_pifba() {
    getDepends libasound2-dev
}

function sources_pifba() {
    gitPullOrClone "$md_build" https://github.com/joolswills/pifba.git
}

function build_pifba() {
    mkdir ".obj"
    make clean
    make
    md_ret_require="$md_build/fba2x"
}

function install_pifba() {
    mkdir "$md_inst/"{roms,skin,preview}
    md_ret_files=(
        'fba2x'
        'capex.cfg'
        'zipname.fba'
        'rominfo.fba'
        'FBACache_windows.zip'
        'fba_029671_clrmame_dat.zip'
    )
    # install fba2x.cfg under another name as we will copy it
    cp -v "$md_build/fba2x.cfg" "$md_inst/fba2x.cfg.sample"
}

function configure_pifba() {
    mkRomDir "fba"
    mkRomDir "neogeo"

    mkUserDir "$configdir/fba"

    # move old config
    if [[ -f "$fba2x.cfg" && ! -h "$fba2x.cfg" ]]; then
        mv "fba2x.cfg" "$configdir/fba/fba2x.cfg"
    fi

    # if the user doesn't already have a config, we will copy the default.
    if [[ ! -f "$configdir/fba/fba2x.cfg" ]]; then
        cp "fba2x.cfg.sample" "$configdir/fba/fba2x.cfg"
    fi

    ln -sf "$configdir/fba/fba2x.cfg"

    addSystem 1 "$md_id" "neogeo" "$md_inst/fba2x %ROM%"
    addSystem 1 "$md_id" "fba arcade" "$md_inst/fba2x %ROM%"
}
