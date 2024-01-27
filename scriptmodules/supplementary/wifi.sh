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
rp_module_desc="Configure WiFi"
rp_module_section="config"
rp_module_flags="!x11"

function _get_interface_wifi() {
    local iface
    # look for the first wireless interface present
    for iface in /sys/class/net/*; do
        if [[ -d "$iface/wireless" ]]; then
            echo "$(basename $iface)"
            return 0
        fi
    done
    return 1
}

function _get_mgmt_tool_wifi() {
    # get the WiFi connection manager
    if systemctl -q is-active NetworkManager.service; then
        echo "nm"
    else
        echo "wpasupplicant"
    fi
}
function _set_interface_wifi() {
    local iface="$1"
    local state="$2"

    if [[ "$state" == "up" ]]; then
        if ! ifup $iface; then
            ip link set $iface up
        fi
    elif [[ "$state" == "down" ]]; then
        if ! ifdown $iface; then
            ip link set $iface down
        fi
    fi
}

function remove_nm_wifi() {
    local iface="$1"
    # delete the NM connection named RetroPie-WiFi
    nmcli connection delete RetroPie-WiFi
    _set_interface_wifi $iface down 2>/dev/null
}

function remove_wpasupplicant_wifi() {
    local iface="$1"
    sed -i '/RETROPIE CONFIG START/,/RETROPIE CONFIG END/d' "/etc/wpa_supplicant/wpa_supplicant.conf"
    _set_interface_wifi $iface down 2>/dev/null
}

function list_wifi() {
    local line
    local essid
    local type
    local iface="$1"

    while read line; do
        [[ "$line" =~ ^Cell && -n "$essid" ]] && echo -e "$essid\n$type"
        [[ "$line" =~ ^ESSID ]] && essid=$(echo "$line" | cut -d\" -f2)
        [[ "$line" == "Encryption key:off" ]] && type="open"
        [[ "$line" == "Encryption key:on" ]] && type="wep"
        [[ "$line" =~ ^IE:.*WPA ]] && type="wpa"
    done < <(iwlist $iface scan | grep -o "Cell .*\|ESSID:\".*\"\|IE: .*WPA\|Encryption key:.*")
    echo -e "$essid\n$type"
}

function connect_wifi() {
    local iface
    local mgmt_tool="wpasupplicant"

    iface="$(_get_interface_wifi)"
    if [[ -z "$iface" ]]; then
        printMsgs "dialog" "No wireless interfaces detected"
        return 1
    fi
    mgmt_tool="$(_get_mgmt_tool_wifi)"

    local essids=()
    local essid
    local types=()
    local type
    local options=()
    i=0
    _set_interface_wifi $iface up 2>/dev/null
    dialog --infobox "\nScanning for WiFi networks..." 5 40 > /dev/tty
    sleep 1

    while read essid; read type; do
        essids+=("$essid")
        types+=("$type")
        options+=("$i" "$essid")
        ((i++))
    done < <(list_wifi $iface)
    options+=("H" "Hidden ESSID")

    local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the WiFi network you would like to connect to" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local hidden=0
    if [[ "$choice" == "H" ]]; then
        essid=$(inputBox "ESSID" "" 4)
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
        local key_min
        if [[ "$type" == "wpa" ]]; then
            key_min=8
        else
            key_min=5
        fi

        cmd=(inputBox "WiFi key/password" "" $key_min)
        local key_ok=0
        while [[ $key_ok -eq 0 ]]; do
            key=$("${cmd[@]}") || return
            key_ok=1
        done
    fi

    create_${mgmt_tool}_config_wifi "$type" "$essid" "$key" "$iface"
    gui_connect_wifi "$iface"
}

function create_nm_config_wifi() {
    local type="$1"
    local essid="$2"
    local key="$3"
    local dev="$4"
    local con="RetroPie-WiFi"

    remove_nm_wifi
    nmcli connection add type wifi ifname "$dev" ssid "$essid" con-name "$con" autoconnect yes
    # configure security for the connection
    case $type in
        wpa)
            nmcli connection modify "$con" \
                wifi-sec.key-mgmt wpa-psk  \
                wifi-sec.psk-flags 0       \
                wifi-sec.psk "$key"
            ;;
        wep)
            nmcli connection modify "$con" \
                wifi-sec.key-mgmt none     \
                wifi-sec.wep-key-flags 0   \
                wifi-sec.wep-key-type 2    \
                wifi-sec.wep-key0 "$key"
            ;;
        open)
            ;;
    esac

    [[ $hidden -eq 1 ]] && nmcli connection modify "$con" wifi.hidden yes
}

function create_wpasupplicant_config_wifi() {
    local type="$1"
    local essid="$2"
    local key="$3"
    local dev="$4"

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

    remove_wpasupplicant_wifi
    wpa_config=$(echo -e "$wpa_config")
    cat >> "/etc/wpa_supplicant/wpa_supplicant.conf" <<_EOF_
# RETROPIE CONFIG START
network={
$wpa_config
}
# RETROPIE CONFIG END
_EOF_
}

function gui_connect_wifi() {
    local iface="$1"
    local mgmt_tool

    mgmt_tool="$(_get_mgmt_tool_wifi)"
    _set_interface_wifi $iface down 2>/dev/null
    _set_interface_wifi $iface up 2>/dev/null

    if [[ "$mgmt_tool" == "wpasupplicant" ]]; then
        # BEGIN workaround for dhcpcd trigger failure on Raspbian stretch
        systemctl restart dhcpcd &>/dev/null
        # END workaround
    fi
    if [[ "$mgmt_tool" == "nm" ]]; then
        nmcli -w 0 connection up RetroPie-WiFi
    fi

    dialog --backtitle "$__backtitle" --infobox "\nConnecting ..." 5 40 >/dev/tty
    local id=""
    i=0
    while [[ -z "$id" && $i -lt 30 ]]; do
        sleep 1
        id=$(iwgetid -r)
        ((i++))
    done
    if [[ -z "$id" ]]; then
        printMsgs "dialog" "Unable to connect to network $essid"
        _set_interface_wifi $iface down 2>/dev/null
    fi
}

function _check_country_wifi() {
    local country
    country="$(raspi-config nonint get_wifi_country)"
    if [[ -z "$country" ]]; then
        if dialog --defaultno --yesno "You don't currently have your WiFi country set.\n\nOn a Raspberry Pi 3B+ and later your WiFi will be disabled until the country is set. You can do this via raspi-config which is available from the RetroPie menu in Emulation Station. Once in raspi-config you can set your country via menu 5 (Localisation Options)\n\nDo you want me to launch raspi-config for you now ?" 22 76 2>&1 >/dev/tty; then
            raspi-config
        fi
    fi
}

function gui_wifi() {

    isPlatform "rpi" && _check_country_wifi

    local default
    local iface
    local mgmt_tool

    iface="$(_get_interface_wifi)"
    mgmt_tool="$(_get_mgmt_tool_wifi)"

    while true; do
        local ip_current="$(getIPAddress)"
        local ip_wlan="$(getIPAddress $iface)"
        local cmd=(dialog --backtitle "$__backtitle" --colors --cancel-label "Exit" --item-help --help-button --default-item "$default" --title "Configure WiFi" --menu "Current IP: \Zb${ip_current:-(unknown)}\ZB\nWireless IP: \Zb${ip_wlan:-(unknown)}\ZB\nWireless ESSID: \Zb$(iwgetid -r || echo "none")\ZB" 22 76 16)
        local options=(
            1 "Connect to WiFi network"
            "1 Connect to your WiFi network"
            2 "Disconnect/Remove WiFi config"
            "2 Disconnect and remove any WiFi configuration"
            3 "Import WiFi credentials from wifikeyfile.txt"
            "3 Will import the SSID (network name) and PSK (password) from the 'wifikeyfile.txt' file on the boot partition

The file should contain two lines as follows\n\nssid = \"YOUR WIFI SSID\"\npsk = \"YOUR PASSWORD\""
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        default="$choice"

        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    connect_wifi $iface
                    ;;
                2)
                    dialog --defaultno --yesno "This will remove the WiFi configuration and stop the WiFi.\n\nAre you sure you want to continue ?" 12 60 2>&1 >/dev/tty
                    [[ $? -ne 0 ]] && continue
                    remove_${mgmt_tool}_wifi $iface
                    ;;
                3)
                    # check in `/boot/` (pre-bookworm) and `/boot/firmware` (bookworm and later) for the file
                    local file="/boot/wifikeyfile.txt"
                    [[ ! -f "$file" ]] && file="/boot/firmware/wifikeyfile.txt"

                    if [[ -f "$file" ]]; then
                        iniConfig " = " "\"" "$file"
                        iniGet "ssid"
                        local ssid="$ini_value"
                        iniGet "psk"
                        local psk="$ini_value"
                        create_${mgmt_tool}_config_wifi "wpa" "$ssid" "$psk" "$iface"
                        gui_connect_wifi "$iface"
                    else
                        printMsgs "dialog" "File 'wifikeyfile.txt' not found on the boot partition!"
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}
