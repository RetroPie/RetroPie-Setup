#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="usbromservice"
rp_module_desc="USB ROM Service"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function depends_usbromservice() {
    getDepends usbmount rsync
}

function enable_usbromservice() {
    cp -v "$scriptdir/scriptmodules/$md_type/$md_id/01_retropie_copyroms" /etc/usbmount/mount.d/
    sed -i -e "s/USERTOBECHOSEN/$user/g" /etc/usbmount/mount.d/01_retropie_copyroms
    chmod +x /etc/usbmount/mount.d/01_retropie_copyroms
}

function disable_usbromservice() {
    rm -f /etc/usbmount/mount.d/01_retropie_copyroms
}

function remove_usbromservice() {
    disable_usbromservice
    apt-get remove -y usbmount
}

function configure_usbromservice() {
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Choose from an option below." 22 86 16)
        options=(
            1 "Enable USB ROM Service"
            2 "Disable USB ROM Service"
            3 "Remove usbmount daemon"
        )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
            case $choices in
                1)
                    rp_callModule "$md_id" depends
                    rp_callModule "$md_id" enable
                    printMsgs "dialog" "Enabled $md_desc"
                    ;;
                2)
                    rp_callModule "$md_id" disable
                    printMsgs "dialog" "Disabled $md_desc"
                    ;;
                3)
                    rp_callModule "$md_id" remove
                    printMsgs "dialog" "Removed $md_desc"
                    ;;
            esac
        else
            break
        fi
    done
}
