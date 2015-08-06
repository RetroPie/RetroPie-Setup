#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="esthemesimple"
rp_module_desc="EmulationStation Theme Simple"
rp_module_menus="2+"
rp_module_flags="nobin"

function sources_esthemesimple() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/es-theme-simple
}

function install_esthemesimple() {
    # remove old simple theme files
    rmDirExists "/etc/emulationstation/themes/simple"

    mkdir -p "/etc/emulationstation/themes/simple"
    
    # copy theme
    cp -r "$md_build/"* "/etc/emulationstation/themes/simple/"
}