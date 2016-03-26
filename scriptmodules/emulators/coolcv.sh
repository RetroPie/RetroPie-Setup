#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="coolcv"
rp_module_desc="CoolCV Colecovision Emulator"
rp_module_menus="4+"
rp_module_flags="!x86 !x11 !mali"

function install_coolcv() {    
    wget -O- -q $__archive_url/coolcv.tar.gz | tar -xvz -C "$md_inst"
}

function configure_coolcv() {
    mkRomDir "coleco"

    moveConfigFile "$home/coolcv_mapping.txt" "$md_conf_root/coleco/coolcv_mapping.txt"

    addSystem 1 "$md_id" "coleco colecovision colecovision" "$md_inst/coolcv/coolcv_pi %ROM%"
}
