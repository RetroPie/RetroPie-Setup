#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation-omx"
rp_module_desc="EmulationStation with OMX Player and Screensaver, based on fieldofcows's OMX Player work, iterated on by pjft."
rp_module_licence="MIT https://raw.githubusercontent.com/pjft/EmulationStation/master/LICENSE.md"
rp_module_section="exp"

function depends_emulationstation-omx() {
    depends_emulationstation
}

function sources_emulationstation-omx() {
    sources_emulationstation "https://github.com/pjft/EmulationStation" "ES-OMX-Master-Merged-Stable"
}

function build_emulationstation-omx() {
    build_emulationstation
}

function install_emulationstation-omx() {
    install_emulationstation
}

function configure_emulationstation-omx() {
    configure_emulationstation
}

function gui_emulationstation-omx() {
    gui_emulationstation
}
