#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="usbromservice"
rp_module_desc="USB ROM Service"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_usbromservice() {
    getDepends usbmount rsync
}

function enable_usbromservice() {
    cp -v $scriptdir/supplementary/01_retropie_copyroms /etc/usbmount/mount.d/
    sed -i -e "s/USERTOBECHOSEN/$user/g" /etc/usbmount/mount.d/01_retropie_copyroms
    chmod +x /etc/usbmount/mount.d/01_retropie_copyroms
}

function disable_usbromservice() {
    rm -f etc/usbmount/mount.d/01_retropie_copyroms
}

function configure_usbromservice() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose from an option below." 22 86 16)
    options=(
        1 "Enable USB ROM Service"
        2 "Disable USB ROM Service"
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                enable_usbromservice
                printMsgs "dialog" "Enabled $md_desc"
                ;;
            2)
                disable_usbromservice
                printMsgs "dialog" "Disabled $md_desc"
                ;;
        esac
    fi
}
