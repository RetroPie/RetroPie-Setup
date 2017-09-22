#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xarcade2jstick"
rp_module_desc="Xarcade2Jstick"
rp_module_section="driver"
rp_module_flags="noinstclean"

function sources_xarcade2jstick() {
    gitPullOrClone "$md_inst" https://github.com/petrockblog/Xarcade2Joystick.git
}

function build_xarcade2jstick() {
    cd "$md_inst"
    make
}

function install_xarcade2jstick() {
    cd "$md_inst"
    make install
}

function remove_xarcade2jstick() {
    cd "$md_inst"
    make uninstallservice
}

function gui_xarcade2jstick() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Disable Xarcade2Jstick service."
        2 "Enable Xarcade2Jstick service."
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                cd "$md_inst"
                make uninstallservice
                printMsgs "dialog" "Disabled Xarcade2Jstick."
                ;;
            2)
                cd "$md_inst"
                make installservice
                printMsgs "dialog" "Enabled Xarcade2Jstick service."
                ;;
        esac
    fi
}
