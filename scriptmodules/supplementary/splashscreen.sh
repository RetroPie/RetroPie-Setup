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

function install_splashscreen() {
    cp "$scriptdir/scriptmodules/$md_type/$md_id/asplashscreen" "/etc/init.d/"
    gitPullOrClone "$md_inst" https://github.com/RetroPie/retropie-splashscreens.git
}

function default_splashscreen() {
    find "$md_inst/retropie2015-blue" -type f >/etc/splashscreen.list
}

function enable_splashscreen() {
    insserv asplashscreen
}

function disable_splashscreen() {
    insserv -r asplashscreen
}

function choose_splashscreen() {
    local options=()
    local i=0
    local splashdir
    while read splashdir; do
        splashdir=${splashdir/$md_inst\//}
        options+=("$i" "$splashdir")
        ((i++))
    done < <(find "$md_inst" -mindepth 1 -maxdepth 1 -type d | sort)
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        choice=$((choice*2+1))
        splashdir=${options[choice]}
        find "$md_inst/$splashdir" -type f >/etc/splashscreen.list
        printMsgs "dialog" "Splashscreen set to '$splashdir'."
    fi
}


function configure_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen install
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    local options=(
        1 "Enable custom splashscreen on boot"
        2 "Disable custom splashscreen on boot"
        3 "Use default splashscreen"
        4 "Choose splashscreen"
        5 "Manually edit splashscreen list"
    )
    while true; do
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    [[ ! -f /etc/splashscreen.list ]] && rp_CallModule splashscreen default
                    enable_splashscreen
                    printMsgs "dialog" "Enabled custom splashscreen on boot."
                    ;;
                2)
                    disable_splashscreen
                    printMsgs "dialog" "Disabled custom splashscreen on boot."
                    ;;
                3)
                    default_splashscreen
                    printMsgs "dialog" "Splashscreen set to RetroPie default."
                    ;;
                4)
                    choose_splashscreen
                    ;;
                5)
                    editFile /etc/splashscreen.list
                    ;;
            esac
        else
            break
        fi
    done
}
