#!/usr/bin/env bash

# This file is part of the microplay-hub Project
# Own Scripts useable for RetroPie and offshoot
#
# The microplay-hub Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the main directory of this distribution and
#
# The Core script is based on The RetroPie Project https://retropie.org.uk Modules
##

rp_module_id="wiringPi"
rp_module_desc="GPIO driver for Raspberry-Pi SBC-Boards"
rp_module_repo="git https://github.com/WiringPi/WiringPi master"
rp_module_section="driver"
rp_module_flags="noinstclean !all rpi"

function sources_wiringPi() {
    gitPullOrClone
}

function depends_wiringPi() {
    local depends=(cmake)
     getDepends "${depends[@]}"
}

function sources_wiringPi() {
    if [[ -d "$md_inst" ]]; then
        git -C "$md_inst" reset --hard  # ensure that no local changes exist
    fi
    gitPullOrClone "$md_inst"
}

function install_wiringPi() {
    cd "$md_inst"
	./build clean
	./build 
}

function remove_wiringPi() {
    cd "$md_inst"
    ./build uninstall
	rm -rf "$md_inst"
}

function showgpio_wiringPi() {
    gpio readall
	sleep 10
}

function gui_wiringPi() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Show my GPIO Pins (10sec)"

    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
				showgpio_wiringPi
                printMsgs "dialog" "Show my GPIO Pins \n\nto see it longer open the command line and type\n\ngpio readall"
                ;;
        esac
    fi
}
