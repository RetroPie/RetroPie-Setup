#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation-piflavor"
rp_module_desc="EmulationStation - Raspberry Pi Flavored"
rp_module_section="exp"

function depends_emulationstation-piflavor() {
    depends_emulationstation
}

function sources_emulationstation-piflavor() {
    sources_emulationstation "https://github.com/jacobfk20/EmulationStation-RPiE"
}

function build_emulationstation-piflavor() {
    build_emulationstation
}

function install_emulationstation-piflavor() {
    install_emulationstation
}

function remove_emulationstation-piflavor() {
    remove_emulationstation
}

function configure_emulationstation-piflavor() {
    configure_emulationstation
}

function gui_emulationstation-piflavor() {
    gui_emulationstation
}
