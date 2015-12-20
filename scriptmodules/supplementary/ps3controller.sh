#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ps3controller"
rp_module_desc="Install/Pair PS3 controller"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function depends_ps3controller() {
    getDepends checkinstall libusb-dev bluetooth libbluetooth-dev joystick
}

function sources_ps3controller() {
    local branch="$1"
    gitPullOrClone "$md_build/sixad" https://github.com/RetroPie/sixad.git $branch
}

function build_ps3controller() {
    cd sixad
    make clean
    make DEVICE_SHORT_NAME=1
}

function install_ps3controller() {
    cd sixad
    checkinstall -y --fstrans=no
    insserv sixad

    # Start sixad daemon
    /etc/init.d/sixad start
}

function remove_ps3controller() {
    service sixad stop
    insserv -r sixad
    dpkg --purge sixad
    rm -f /etc/udev/rules.d/99-sixpair.rules
    rm -f /etc/udev/rules.d/10-local.rules
    rm -rf "$md_inst"
}

function pair_ps3controller() {
    if [[ ! -f "/usr/sbin/sixpair" ]]; then
        local mode
        local branch="$1"
        for mode in depends sources build install; do
            rp_callModule ps3controller $mode $branch
        done
    fi

    printMsgs "dialog" "The driver and configuration tools for connecting PS3 controllers have been installed. \n\nPlease connect your PS3 controller now or anytime to its USB connection, to setup Bluetooth connection. \n\nAfterwards disconnect your PS3 controller from its USB connection, and press the PS button to connect via Bluetooth."
    # enable old behaviour. run "sixad-helper sixpair" "now" for users who do not read info text 
    sixad-helper sixpair
}

function configure_ps3controller() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Install/Pair PS3 controller"
            2 "Install/Pair PS3 controller (clone support)"
            3 "Remove PS3 controller configurations"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    rp_callModule "$md_id" pair
                    ;;
                2)
                    rp_callModule "$md_id" pair gasia
                    ;;
                3)
                    rp_callModule "$md_id" remove
                    printMsgs "dialog" "Removed PS3 controller configurations"
                    ;;
            esac
        else
            break
        fi
    done
}
