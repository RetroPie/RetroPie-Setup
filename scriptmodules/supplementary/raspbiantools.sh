#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="raspbiantools"
rp_module_desc="Raspbian related tools"
rp_module_menus="3+"
rp_module_flags="nobin"

function apt_upgrade_raspbiantools() {
    aptUpdate
    apt-get -y upgrade
}

function package_cleanup_raspbiantools() {
    # remove PulseAudio since this is slowing down the whole system significantly. Cups is also not needed
    apt-get remove -y pulseaudio cups wolfram-engine sonic-pi
    apt-get -y autoremove
}

function disable_blanker_raspbiantools() {
    sed -i 's/BLANK_TIME=30/BLANK_TIME=0/g' /etc/kbd/config
    sed -i 's/POWERDOWN_TIME=30/POWERDOWN_TIME=0/g' /etc/kbd/config
}

function enable_modules_raspbiantools() {
    sed -i '/snd_bcm2835/d' /etc/modules

    for module in uinput joydev snd-bcm2835; do
        modprobe $module
        if ! grep -q "$module" /etc/modules; then
            addLineToFile "$module" "/etc/modules"
        else
            echo "$module module already contained in /etc/modules"
        fi
    done
}

function configure_raspbiantools() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Upgrade Raspbian packages"
            2 "Remove some uneeded packages (pulseaudio / cups / wolfram)"
            3 "Disable screen blanker"
            4 "Enable needed kernel modules (uinput joydev snd-bcm2835)"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    rp_callModule "$md_id" apt_upgrade
                    ;;
                2)
                    rp_callModule "$md_id" package_cleanup
                    ;;
                3)
                    rp_callModule "$md_id" disable_blanker
                    ;;
                4)
                    rp_callModule "$md_id" enable_modules
                    ;;
            esac
        else
            break
        fi
    done
}
