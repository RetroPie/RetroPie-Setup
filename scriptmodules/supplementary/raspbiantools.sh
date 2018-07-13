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
rp_module_section="config"
rp_module_flags="!x11 !mali"

function apt_upgrade_raspbiantools() {
    aptUpdate
    apt-get -y dist-upgrade
}

function lxde_raspbiantools() {
    aptInstall --no-install-recommends xorg lxde
    aptInstall raspberrypi-ui-mods rpi-chromium-mods gvfs

    setConfigRoot "ports"
    addPort "lxde" "lxde" "Desktop" "startx"
    enable_autostart
}

function package_cleanup_raspbiantools() {
    # remove PulseAudio since this is slowing down the whole system significantly. Cups is also not needed
    apt-get remove -y pulseaudio cups wolfram-engine sonic-pi
    apt-get -y autoremove
}

function disable_blanker_raspbiantools() {
    sed -i 's/BLANK_TIME=\d*/BLANK_TIME=0/g' /etc/kbd/config
    sed -i 's/POWERDOWN_TIME=\d*/POWERDOWN_TIME=0/g' /etc/kbd/config
}

function enable_modules_raspbiantools() {
    sed -i '/snd_bcm2835/d' /etc/modules

    local modules=(uinput)

    local module
    for module in "${modules[@]}"; do
        modprobe $module
        if ! grep -q "$module" /etc/modules; then
            addLineToFile "$module" "/etc/modules"
        else
            echo "$module module already contained in /etc/modules"
        fi
    done
}

function gui_raspbiantools() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Upgrade Raspbian packages"
            2 "Install Pixel desktop environment"
            3 "Remove some unneeded packages (pulseaudio / cups / wolfram)"
            4 "Disable screen blanker"
            5 "Enable needed kernel module uinput"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rp_callModule "$md_id" apt_upgrade
                    ;;
                2)
                    dialog --defaultno --yesno "Are you sure you want to install the Pixel desktop?" 22 76 2>&1 >/dev/tty || continue
                    rp_callModule "$md_id" lxde
                    printMsgs "dialog" "Pixel desktop/LXDE is installed."
                    ;;
                3)
                    rp_callModule "$md_id" package_cleanup
                    ;;
                4)
                    rp_callModule "$md_id" disable_blanker
                    ;;
                5)
                    rp_callModule "$md_id" enable_modules
                    ;;
            esac
        else
            break
        fi
    done
}
