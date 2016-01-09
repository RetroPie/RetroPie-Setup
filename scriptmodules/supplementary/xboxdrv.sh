#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xboxdrv"
rp_module_desc="Xbox / Xbox 360 gamepad driver"
rp_module_menus="3+gui"

function depends_xboxdrv() {
    hasPackage xboxdrv && apt-get remove -y xboxdrv
    getDepends libboost-dev libusb-1.0-0-dev libudev-dev libx11-dev scons pkg-config x11proto-core-dev libdbus-glib-1-dev
}

function sources_xboxdrv() {
    gitPullOrClone "$md_build" https://github.com/xboxdrv/xboxdrv.git stable
}

function build_xboxdrv() {
    scons
}

function install_xboxdrv() {
    make install PREFIX="$md_inst"
}

function enable_xboxdrv() {
    if [[ -n "$1" ]]; then

        # Because function return codes are limited to 0-255 range, we could not leave this calculation in the deadzone_xboxdrv routine or we'd get weird results.
        local deadzone="$((($2-1) * 500))"

	local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --dbus disabled --detach-kernel-driver --id 0 --led 2 --deadzone $deadzone --silent --trigger-as-button"
        local loop="1"

	while [ "$loop" -lt "$1" ]
        do
            config+=" --next-controller --id $loop --led $(($loop+2)) --deadzone $deadzone --silent --trigger-as-button"
            loop=$(($loop+1))
        done
    fi
    
    if ! grep -q "xboxdrv" /etc/rc.local; then
        sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
        printMsgs "dialog" "xboxdrv enabled in /etc/rc.local with the following config\n\n$config\n\nIt will be started on next boot."
    else
        printMsgs "dialog" "xboxdrv is already enabled in /etc/rc.local with the following config\n\n$(grep "xboxdrv" /etc/rc.local)"
    fi
}

function disable_xboxdrv() {
    sed -i "/xboxdrv/d" /etc/rc.local
    printMsgs "dialog" "xboxdrv configuration in /etc/rc.local has been removed."
}

function numcontrollers_xboxdrv() {
    local controllers="$1"
    local cmd=(dialog --backtitle "$__backtitle" --default-item "2" --menu "Select the number of controllers to enable" 22 86 16)
    local options=(
        1 "1 controller"
        2 "2 controllers"
        3 "3 controllers"
        4 "4 controllers"
    )

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            controllers="$choice"
            break
        else
            break
        fi
    done
    return "$controllers"
}

function deadzone_xboxdrv() {
    local deadzone="$1"
    local cmd=(dialog --backtitle "$__backtitle" --default-item "9" --menu "Select range of your analog stick deadzone" 22 86 16)
    local options=(
        1 "No Deadzone"
        2 "0-500"
        3 "0-1000"
        4 "0-1500"
        5 "0-2000"
        6 "0-2500"
        7 "0-3000"
        8 "0-3500"
        9 "0-4000"
       10 "0-4500"
       11 "0-5000"
       12 "0-5500"
       13 "0-6000"
    )

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            deadzone="$choice"
            break
        else
            break
        fi
    done
    return "$deadzone"
}


function configure_xboxdrv() {
    # make sure existing configs will point to the new xboxdrv
    sed -i "s|^xboxdrv|\"$md_inst/bin/xboxdrv\"|" /etc/rc.local
}

function gui_xboxdrv() {
    if [[ ! -f "$md_inst/bin/xboxdrv" ]]; then
        rp_callModule "$md_id" depends
        rp_callModule "$md_id" install_bin
        rp_callModule "$md_id" configure
    fi
    iniConfig "=" "" "/boot/config.txt"
    local controllers_wanted="2"
    local deadzone_wanted="9"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable xboxdrv"
        2 "Disable xboxdrv"
        3 "Set number of controllers to enable"
        4 "Set analog stick deadzone"
        5 "Set dwc_otg.speed=1 in /boot/config.txt"
        6 "Remove dwc_otg.speed=1 from /boot/config.txt"
    )

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then

            case $choice in
                1)
                    enable_xboxdrv "$controllers_wanted" "$deadzone_wanted"
                    ;;
                2)
                    disable_xboxdrv
                    ;;
                3)
                    numcontrollers_xboxdrv "$controllers_wanted"
                    controllers_wanted="$?"
                    ;;
                4)
                    deadzone_xboxdrv "$deadzone_wanted"
                    deadzone_wanted="$?"
                    ;;
                5)
                    iniSet "dwc_otg.speed" "1"
                    printMsgs "dialog" "dwc_otg.speed=1 has been set in /boot/config.txt"
                    ;;
                6)
                    iniDel "dwc_otg.speed"
                    printMsgs "dialog" "dwc_otg.speed=1 has been removed from /boot/config.txt"
                    ;;
            esac
        else
            break
        fi
    done
}
