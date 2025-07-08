#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="powerblock"
rp_module_desc="PowerBlock Driver"
rp_module_help="Please note that you need to manually enable or disable the PowerBlock Service in the Configuration section. IMPORTANT: If the service is enabled and the power switch functionality is enabled (which is the default setting) in the config file, you need to have a switch connected to the PowerBlock."
rp_module_repo="git https://github.com/petrockblog/PowerBlock.git master"
rp_module_section="driver"
rp_module_flags="noinstclean !all rpi"

function depends_powerblock() {
    local depends=(cmake doxygen)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)

    getDepends "${depends[@]}"
}

function sources_powerblock() {
    if [[ -d "$md_inst" ]]; then
        git -C "$md_inst" reset --hard  # ensure that no local changes exist
    fi
    gitPullOrClone "$md_inst"
}

function install_powerblock() {
    cd "$md_inst"
    bash install.sh
}

function remove_powerblock() {
    cd "$md_inst"
    bash uninstall.sh
}

function gui_powerblock() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable PowerBlock driver"
        2 "Disable PowerBlock driver"

    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                install_powerblock
                printMsgs "dialog" "Enabled PowerBlock driver."
                ;;
            2)
                remove_powerblock
                printMsgs "dialog" "Disabled PowerBlock driver."
                ;;
        esac
    fi
}
