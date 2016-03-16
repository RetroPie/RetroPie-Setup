#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wifi"
rp_module_desc="Configure Wifi"
rp_module_menus="3+"
rp_module_flags="nobin !x86"

function remove_wifi() {
    sed -i '/RETROPIE CONFIG START/,/RETROPIE CONFIG END/d' "/etc/wpa_supplicant/wpa_supplicant.conf"
    ifdown wlan0 &>/dev/null
}

function list_wifi() {
    local line
    local essid
    local type
    while read line; do
        [[ "$line" =~ ^Cell && -n "$essid" ]] && echo -e "$essid\n$type"
        [[ "$line" =~ ^ESSID ]] && essid=$(echo "$line" | cut -d\" -f2)
        [[ "$line" == "Encryption key:off" ]] && type="open"
        [[ "$line" == "Encryption key:on" ]] && type="wep"
        [[ "$line" =~ ^IE:.*WPA ]] && type="wpa"
    done < <(iwlist wlan0 scan | grep -o "Cell .*\|ESSID:\".*\"\|IE: .*WPA\|Encryption key:.*")
    echo -e "$essid\n$type"
}

function connect_wifi() {
    local essids=()
    local essid
    local types=()
    local type
    local options=()
    i=0
    while read essid; read type; do
        essids+=("$essid")
        types+=("$type")
        options+=("$i" "$essid")
        ((i++))
    done < <(list_wifi)
    options+=("H" "Hidden ESSID")

    local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the network you would like to connect to" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local hidden=0
    if [[ "$choice" == "H" ]]; then
        cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the ESSID" 10 60)
        essid=$("${cmd[@]}" 2>&1 >/dev/tty)
        [[ -z "$essid" ]] && return
        cmd=(dialog --backtitle "$__backtitle" --nocancel --menu "Please choose the WiFi type" 12 40 6)
        options=(
            wpa "WPA/WPA2"
            wep "WEP"
            open "Open"
        )
        type=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        hidden=1
    else
        essid=${essids[choice]}
        type=${types[choice]}
    fi

    if [[ "$type" == "wpa" || "$type" == "wep" ]]; then
        local key=""
        cmd=(dialog --backtitle "$__backtitle" --insecure --passwordbox "Please enter the WiFi key/password for $essid" 10 63)
        local key_ok=0
        while [[ $key_ok -eq 0 ]]; do
            key=$("${cmd[@]}" 2>&1 >/dev/tty) || return
            key_ok=1
            if [[ ${#key} -lt 8 || ${#key} -gt 63 ]] && [[ "$type" == "wpa" ]]; then
                printMsgs "dialog" "Password must be between 8 and 63 characters"
                key_ok=0
            fi
            if [[ -z "$key" && $type == "wep" ]]; then
                printMsgs "dialog" "Password cannot be empty"
                key_ok=0
            fi
        done
    fi

    local wpa_config
    wpa_config+="\tssid=\"$essid\"\n"
    case $type in
        wpa)
            wpa_config+="\tpsk=\"$key\"\n"
            ;;
        wep)
            wpa_config+="\tkey_mgmt=NONE\n"
            wpa_config+="\twep_tx_keyidx=0\n"
            wpa_config+="\twep_key0=$key\n"
            ;;
        open)
            wpa_config+="\tkey_mgmt=NONE\n"
            ;;
    esac
    
    [[ $hidden -eq 1 ]] &&  wpa_config+="\tscan_ssid=1\n"

    remove_wifi
    wpa_config=$(echo -e "$wpa_config")
    cat >> "/etc/wpa_supplicant/wpa_supplicant.conf" <<_EOF_
# RETROPIE CONFIG START
network={
$wpa_config
}
# RETROPIE CONFIG END
_EOF_

    ifup wlan0 &>/dev/null
    local id=""
    i=0
    while [[ -z "$id" && $i -lt 20 ]]; do
        sleep 1
        id=$(iwgetid -r)
        ((i++))
    done
    [[ -z "$id" ]] && printMsgs "dialog" "Unable to connect to network $essid"
}

function configure_wifi() {
    while true; do
        local ip_int=$(ip route get 8.8.8.8 2>/dev/null | head -1 | cut -d' ' -f8)
        local cmd=(dialog --backtitle "$__backtitle" --menu "Configure WiFi\nCurrent IP: $ip_int\nWireless ESSID: $(iwgetid -r)" 22 76 16)
        local options=(
            1 "Connect to WiFi network"
            2 "Disconnect/Remove WiFi config"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    connect_wifi
                    ;;
                2)
                    remove_wifi
                    ;;
            esac
        else
            break
        fi
    done
}
