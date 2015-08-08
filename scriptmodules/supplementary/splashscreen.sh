#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="splashscreen"
rp_module_desc="Configure Splashscreen"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_splashscreen() {
    getDepends fbi omxplayer
}

function enable_splashscreen()
{
    clear
    printHeading "Enabling custom splashscreen on boot."

    cp "$scriptdir/scriptmodules/$md_type/$md_id/splashscreen" "/etc/init.d/"
    chmod +x "/etc/init.d/splashscreen"

    find $scriptdir/supplementary/splashscreens/retropie2015-blue/ -type f > /etc/splashscreen.list

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d splashscreen defaults

    # not-so-elegant hack for later re-enabling the splashscreen
    update-rc.d splashscreen enable
}

function disable_splashscreen()
{
    clear
    printHeading "Disabling custom splashscreen on boot."

    update-rc.d splashscreen disable
}

function choose_splashscreen() {
    printHeading "Configuring splashscreen"

    local options
    local ctr

    ctr=0
    pushd $scriptdir/supplementary/splashscreens/ > /dev/null
    options=()
    dirlist=()
    for splashdir in $(find . -type d | sort) ; do
        if [[ $splashdir != "." ]]; then
            options+=($ctr "${splashdir:2}")
            dirlist+=(${splashdir:2})
            ((ctr++))
        fi
    done
    popd > /dev/null
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    splashdir=${dirlist[$choices]}
    if [[ -n "$choices" ]]; then
        rm /etc/splashscreen.list
        find $scriptdir/supplementary/splashscreens/$splashdir/ -type f | sort | while read line; do
            echo $line >> /etc/splashscreen.list
        done
        printMsgs "dialog" "Splashscreen set to '$splashdir'."
    fi
}

function configure_splashscreen() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(
        1 "Enable custom splashscreen on boot"
        2 "Disable custom splashscreen on boot"
        3 "Choose splashscreen"
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                enable_splashscreen
                printMsgs "dialog" "Enabled custom splashscreen on boot."
                ;;
            2)
                disable_splashscreen
                printMsgs "dialog" "Disabled custom splashscreen on boot."
                ;;
            3)
                choose_splashscreen
                ;;
        esac
    fi
}