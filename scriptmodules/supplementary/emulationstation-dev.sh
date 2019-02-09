#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="emulationstation-dev"
rp_module_desc="EmulationStation (latest development version) - Frontend used by RetroPie for launching emulators"
rp_module_licence="MIT https://raw.githubusercontent.com/RetroPie/EmulationStation/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="frontend"

function _update_hook_emulationstation-dev() {
    _update_hook_emulationstation
}

function _add_system_emulationstation-dev() {
    _add_system_emulationstation "$@"
}

function _del_system_emulationstation-dev() {
    _del_system_emulationstation "$@"
}

function _add_rom_emulationstation-dev() {
    _add_rom_emulationstation "$@"
}

function depends_emulationstation-dev() {
    depends_emulationstation
}

function sources_emulationstation-dev() {
    sources_emulationstation "" "master"
}

function build_emulationstation-dev() {
    build_emulationstation
}

function install_emulationstation-dev() {
    install_emulationstation
}

function configure_emulationstation-dev() {
    rp_callModule "emulationstation" remove
    configure_emulationstation
}

function remove_emulationstation-dev() {
    remove_emulationstation
}

function gui_emulationstation-dev() {
    gui_emulationstation
}
