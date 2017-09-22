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


function enable_xarcade2jstick() {
    cd "$md_inst"
    make installservice
}

function disable_xarcade2jstick() {
    cd "$md_inst"
    make uninstallservice
}

function remove_xarcade2jstick() {
    [[ -f /lib/systemd/system/xarcade2jstick.service ]] && disable_xarcade2jstick
    cd "$md_inst"
    make uninstall
}

function gui_xarcade2jstick() {
    local status
    local options=(
        1 "Enable Xarcade2Jstick service."
        2 "Disable Xarcade2Jstick service."
    )
    while true; do
        status="Disabled"
        [[ -f /lib/systemd/system/xarcade2jstick.service ]] && status="Enabled"
        local cmd=(dialog --backtitle "$__backtitle" --menu "Service is currently: $status" 22 86 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1)
                enable_xarcade2jstick
                printMsgs "dialog" "Enabled Xarcade2Jstick."
                ;;
            2)
                disable_xarcade2jstick
                printMsgs "dialog" "Disabled Xarcade2Jstick service."
                ;;
        esac
    done
}
