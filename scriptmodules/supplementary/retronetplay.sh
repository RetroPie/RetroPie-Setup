#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retronetplay"
rp_module_desc="RetroNetplay"
rp_module_section="config"

function rps_retronet_saveconfig() {
    local conf="$configdir/all/retronetplay.cfg"
    cat >"$conf"  <<_EOF_
__netplaymode="$__netplaymode"
__netplayport="$__netplayport"
__netplayhostip="$__netplayhostip"
__netplayhostip_cfile="$__netplayhostip_cfile"
__netplaynickname="'$__netplaynickname'"
_EOF_
    chown $user:$user "$conf"
    printMsgs "dialog" "Configuration has been saved to $conf"
}

function rps_retronet_loadconfig() {
    if [[ -f "$configdir/all/retronetplay.cfg" ]]; then
        source "$configdir/all/retronetplay.cfg"
    else
        __netplayenable="D"
        __netplaymode="H"
        __netplayport="55435"
        __netplayhostip="192.168.0.1"
        __netplayhostip_cfile=""
        __netplaynickname="RetroPie"
    fi
}

function rps_retronet_mode() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Please set the netplay mode." 22 76 16)
    options=(1 "Set as HOST"
             2 "Set as CLIENT" )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
             1) __netplaymode="H"
                __netplayhostip_cfile=""
                ;;
             2) __netplaymode="C"
                __netplayhostip_cfile="$__netplayhostip"
                ;;
        esac
    fi
}

function rps_retronet_port() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the port to be used for netplay (default: 55435)." 22 76 $__netplayport)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        __netplayport="$choice"
    fi
}

function rps_retronet_hostip() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the IP address of the host." 22 76 $__netplayhostip)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        __netplayhostip="$choice"
        if [[ $__netplaymode == "H" ]]; then
            __netplayhostip_cfile=""
        else
            __netplayhostip_cfile="$__netplayhostip"
        fi
    fi
}

function rps_retronet_nickname() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the nickname you wish to use (default: RetroPie)" 22 76 $__netplaynickname)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        __netplaynickname="$choice"
    fi
}

function gui_retronetplay() {
    rps_retronet_loadconfig

    local ip_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    local ip_ext=$(wget -O- -q http://ipecho.net/plain)

    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure RetroArch Netplay.\nInternal IP: $ip_int External IP: $ip_ext" 22 76 16)
        options=(
            1 "Set mode, (H)ost or (C)lient. Currently: $__netplaymode"
            2 "Set port. Currently: $__netplayport"
            3 "Set host IP address (for client mode). Currently: $__netplayhostip"
            4 "Set netplay nickname. Currently: $__netplaynickname"
            5 "Save configuration"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rps_retronet_mode
                    ;;
                2)
                    rps_retronet_port
                    ;;
                3)
                    rps_retronet_hostip
                    ;;
                4)
                    rps_retronet_nickname
                    ;;
                5)
                    rps_retronet_saveconfig
                    ;;
            esac
        else
            break
        fi
    done
}
