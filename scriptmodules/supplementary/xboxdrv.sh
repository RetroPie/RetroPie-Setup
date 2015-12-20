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
rp_module_menus="3+configure"

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
    local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --id 0 --led 2 --deadzone 4000 --silent --trigger-as-button --next-controller --id 1 --led 3 --deadzone 4000 --silent --trigger-as-button --dbus disabled --detach-kernel-driver"
    if ! grep -q "xboxdrv" /etc/rc.local; then
        sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
        printMsgs "dialog" "xbodrv enabled in /etc/rc.local with the following config\n\n$config\n\nIt will be started on next boot."
    else
        # make sure existing configs will point to the new xboxdrv
        sed -i "s|^xboxdrv|\"$md_inst/bin/xboxdrv\"|" /etc/rc.local
        printMsgs "dialog" "xbodrv is already enabled in /etc/rc.local with the following config\n\n$(grep "xboxdrv" /etc/rc.local)"
    fi
}

function disable_xboxdrv() {
    sed -i "/xboxdrv/d" /etc/rc.local
    printMsgs "dialog" "xboxdrv configuration in /etc/rc.local has been removed."
}

function configure_xboxdrv() {
    if [[ ! -f "$md_inst/bin/xboxdrv" ]]; then
        rp_callModule "$md_id" depends
        rp_callModule "$md_id" install_bin
    fi
    iniConfig "=" "" "/boot/config.txt"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable xboxdrv"
        2 "Disable xboxdrv"
        3 "Set dwc_otg.speed=1 in /boot/config.txt"
        4 "Remove dwc_otg.speed=1 from /boot/config.txt"
    )
    iniConfig "=" "" "/boot/config.txt"
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then

            case $choice in
                1)
                    enable_xboxdrv
                    ;;
                2)
                    disable_xboxdrv
                    ;;
                3)
                    iniSet "dwc_otg.speed" "1"
                    printMsgs "dialog" "dwc_otg.speed=1 has been set in /boot/config.txt"
                    ;;
                4)
                    iniDel "dwc_otg.speed"
                    printMsgs "dialog" "dwc_otg.speed=1 has been removed from /boot/config.txt"
                    ;;
            esac
        else
            break
        fi
    done
}