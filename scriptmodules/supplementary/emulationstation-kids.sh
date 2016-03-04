#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation-kids"
rp_module_desc="EmulationStation with additional UI modes (kids / kiosk)"
rp_module_menus="4+"

function depends_emulationstation-kids() {
    depends_emulationstation
}

function sources_emulationstation-kids() {
    sources_emulationstation "https://github.com/zigurana/EmulationStation" "UI_modes_Kiosk_Kid_Full"
}

function build_emulationstation-kids() {
    build_emulationstation
}

function install_emulationstation-kids() {
    install_emulationstation
}

function configure_emulationstation-kids() {
    configure_emulationstation
}
