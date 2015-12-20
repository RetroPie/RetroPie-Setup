#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="splashscreen"
rp_module_desc="Configure Splashscreen"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function depends_splashscreen() {
    getDepends fbi omxplayer
}

function install_splashscreen() {
    cp "$scriptdir/scriptmodules/$md_type/$md_id/asplashscreen" "/etc/init.d/"
    chmod +x /etc/init.d/asplashscreen
    gitPullOrClone "$md_inst" https://github.com/RetroPie/retropie-splashscreens.git

    mkUserDir "$datadir/splashscreens"
    echo "Place your own splashscreen in here, each one with its own folder" >"$datadir/splashscreens/README.txt"
    chown $user:$user "$datadir/splashscreens/README.txt"
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
    local path="$1"
    local options=()
    local i=0
    local splashdir
    while read splashdir; do
        splashdir=${splashdir/$path\//}
        options+=("$i" "$splashdir")
        ((i++))
    done < <(find "$path" -mindepth 1 -maxdepth 1 -type d -not -path "*/.git" | sort)
    if [[ ${#options[@]} -eq 0 ]]; then
        printMsgs "dialog" "There are no splashscreens installed in $path"
        return
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        choice=$((choice*2+1))
        splashdir=${options[choice]}
        find "$path/$splashdir" -type f >/etc/splashscreen.list
        printMsgs "dialog" "Splashscreen set to '$splashdir'."
    fi
}

function configure_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen depends
        rp_callModule splashscreen install
    fi

    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Choose RetroPie splashscreen"
        2 "Choose own splashscreen (from $datadir/splashscreens)"
        3 "Enable custom splashscreen on boot"
        4 "Disable custom splashscreen on boot"
        5 "Use default splashscreen"
        6 "Manually edit splashscreen list"
        7 "Update RetroPie splashscreens"
    )
    while true; do
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    choose_splashscreen "$md_inst"
                    ;;
                2)
                    choose_splashscreen "$datadir/splashscreens"
                    ;;
                3)
                    [[ ! -f /etc/splashscreen.list ]] && rp_CallModule splashscreen default
                    enable_splashscreen
                    printMsgs "dialog" "Enabled custom splashscreen on boot."
                    ;;
                4)
                    disable_splashscreen
                    printMsgs "dialog" "Disabled custom splashscreen on boot."
                    ;;
                5)
                    default_splashscreen
                    printMsgs "dialog" "Splashscreen set to RetroPie default."
                    ;;

                6)
                    editFile /etc/splashscreen.list
                    ;;
                7)
                    rp_callModule splashscreen install
                    ;;
            esac
        else
            break
        fi
    done
}
