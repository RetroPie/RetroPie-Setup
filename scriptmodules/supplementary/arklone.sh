#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="arklone"
rp_module_desc="arklone cloud sync utility by ridgek"
rp_module_licence="GPL3 https://raw.githubusercontent.com/ridgekuhn/arklone-retropie/master/LICENSE.md"
rp_module_repo="git https://github.com/ridgekuhn/arklone-retropie master"
rp_module_section="opt"

function sources_arklone() {
    gitPullOrClone
}

function install_arklone() {
    md_ret_files=(
        'src'
        'LICENSE.md'
        'README.md'
        'install.sh'
        'uninstall.sh'
    )
}

function configure_arklone() {
    if [[ "${md_mode}" = "install" ]]; then
        # Run install script
        "${md_inst}/install.sh"

        # Link to EmulationStation RetroPie menu
        touch "${home}/RetroPie/retropiemenu/arklone.rp"
    fi
}

function gui_arklone() {
    # Run arklone settings manager script
    "${md_inst}/src/dialogs/settings.sh"
}

function remove_arklone() {
    # Run uninstall script
    "${md_inst}/uninstall.sh" true

    # Remove EmulationStation RetroPie menu link
    rm -fv "${home}/RetroPie/retropiemenu/arklone.rp"
}

