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
rp_module_section="config"
rp_module_flags="!x11"

function _set_interface_wifi() {
    local state="$1"

    if [[ "$state" == "up" ]]; then
        if ! ifup wlan0; then
            ip link set wlan0 up
        fi
    elif [[ "$state" == "down" ]]; then
        if ! ifdown wlan0; then
            ip link set wlan0 down
        fi
    fi
}

function remove_wifi() {
    sed -i '/RETROPIE CONFIG START/,/RETROPIE CONFIG END/d' "/etc/wpa_supplicant/wpa_supplicant.conf"
    _set_interface_wifi down 2>/dev/null
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
    if [[ ! -d "/sys/class/net/wlan0/" ]]; then
        printMsgs "dialog" "No wlan0 interface detected"
        return 1
    fi
    local essids=()
    local essid
    local types=()
    local type
    local options=()
    i=0
    _set_interface_wifi up 2>/dev/null
    sleep 1
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

    create_config_wifi "$type" "$essid" "$key"

    gui_connect_wifi
}

function create_config_wifi() {
    local type="$1"
    local essid="$2"
    local key="$3"

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
}

function gui_connect_wifi() {
    _set_interface_wifi down 2>/dev/null
    _set_interface_wifi up 2>/dev/null
    # BEGIN workaround for dhcpcd trigger failure on Raspbian stretch
    systemctl restart dhcpcd &>/dev/null
    # END workaround
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
        _set_interface_wifi down 2>/dev/null
    fi
}

function _check_country_wifi() {
    [[ ! -f /etc/wpa_supplicant/wpa_supplicant.conf ]] && return
    iniConfig "=" "" /etc/wpa_supplicant/wpa_supplicant.conf
    iniGet "country"
    if [[ -z "$ini_value" ]]; then
        if dialog --defaultno --yesno "You don't currently have your WiFi country set in /etc/wpa_supplicant/wpa_supplicant.conf\n\nOn a Raspberry Pi 3 Model B+ your WiFI will be disabled until the country is set. You can do this via raspi-config which is available from the RetroPie menu in Emulation Station. Once in raspi-config you can set your country via menu 4 (Localisation Options)\n\nDo you want me to launch raspi-config for you now ?" 22 76 2>&1 >/dev/tty; then
            raspi-config
        fi
    fi
}

function gui_wifi() {

    isPlatform "rpi" && _check_country_wifi

    local default
    while true; do
        local ip_current="$(getIPAddress)"
        local ip_wlan="$(getIPAddress wlan0)"
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Configure WiFi\nCurrent IP: ${ip_current:-(unknown)}\nWireless IP: ${ip_wlan:-(unknown)}\nWireless ESSID: $(iwgetid -r)" 22 76 16)
        local options=(
            1 "Connect to WiFi network"
            "1 Connect to your WiFi network"
            2 "Disconnect/Remove WiFi config"
            "2 Disconnect and remove any Wifi configuration"
            3 "Import wifi credentials from /boot/wifikeyfile.txt"
            "3 Will import the ssid (name) and psk (password) from a file /boot/wifikeyfile.txt
The file should contain two lines as follows\n\nssid = \"YOUR WIFI SSID\"\npsk = \"YOUR PASSWORD\""
            4 "Connecting via WPS"
            "4 Connecting via Push to Button WPS"
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${choice[@]:0:5}" == "HELP" ]]; then
            choice="${choice[@]:6}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        default="$choice"

        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    connect_wifi
                    ;;
                2)
                    remove_wifi
                    ;;
                3)
                    if [[ -f "/boot/wifikeyfile.txt" ]]; then
                        iniConfig " = " "\"" "/boot/wifikeyfile.txt"
                        iniGet "ssid"
                        local ssid="$ini_value"
                        iniGet "psk"
                        local psk="$ini_value"
                        create_config_wifi "wpa" "$ssid" "$psk"
                        gui_connect_wifi
                    else
                        printMsgs "dialog" "No /boot/wifikeyfile.txt found"
                    fi
                    ;;
                 4)
                    wps_wifi
                    ;;
            esac
        else
            break
        fi
    done
}

function wps_wifi() {
	remove_wifi
	check_country_wifi
	dialog --backtitle "$__backtitle" --infobox "\nConnecting ..." 5 40 >/dev/tty
    if [ "$(LANG=C && /sbin/ifconfig wlan0 | grep 'HWaddr\|ether' | wc -l)" -gt "0" -a "$(LANG=C && /sbin/ip addr show wlan0 | grep 'inet ' | grep -v '169.254' | wc -l)" -lt "1" ]; 
	then killall -q wpa_supplicant
    sleep 1
    # Check if "update_config=1" needed in /etc/wpa_supplicant/wpa_supplicant.conf for Autoconfig
    if [ "$(grep -i "update_config=1" /etc/wpa_supplicant/wpa_supplicant.conf | wc -l)" -lt "1" ]; then
    	echo "update_config=1" >> /etc/wpa_supplicant/wpa_supplicant.conf
    fi
    
    # Make sure WPA-Supplicant is running with config
    # separate RPI3 no wext Driver for WPS!
    if [ "0" -lt "$(wpa_supplicant -h | grep nl80211 | wc -l)" ]; then
    	wpa_supplicant -B w -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
    else
    	wpa_supplicant -B w -D wext -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
    fi
    sleep 3
    
    # Clear network list
    for i in `wpa_cli -iwlan0 list_networks | grep ^[0-9] | cut -f1`; do wpa_cli -iwlan0 remove_network $i; done
    
    # get Routers supporting WPS, sorted by signal strength        
    SSID=$(/sbin/wpa_cli -iwlan0 scan_results | grep "WPS" | sort -r -k3 | awk 'END{print $NF}')
    echo "Using $SSID for WPS"
    #SUCCESS=$(wpa_cli -iwlan0 wps_pbc $SSID)
    SUCCESS=$(wpa_cli -iwlan0 wps_pbc)
    sleep 10
    
    # Check for Entry in wpa_supplicant.conf
    VALIDENTRY=$(grep -i "^network=" /etc/wpa_supplicant/wpa_supplicant.conf | wc -l)
    
    # wpa_supplicant.conf should be modified in last 20 seconds by WPS Config
    MODIFIED=$(( `date +%s` - `stat -L --format %Y /etc/wpa_supplicant/wpa_supplicant.conf` ))
    
    if [ "$(echo "$SUCCESS" | grep 'OK' | wc -l)" -gt "0" -a "$VALIDENTRY" -gt "0" -a "$MODIFIED" -lt "20" ]; then
    	# Now Config File should be written    	
    	
    	# Stop existing WPA_Supplicant Process with Old Config
    	killall -q wpa_supplicant
    	sleep 3
    	
    	# Enable wlan0 in /etc/network/interfaces
    	if [ "$(grep -i '^auto wlan0' /etc/network/interfaces | wc -l)" -lt "1" ]; then
    		sed -i "s/#allow-hotplug wlan0/allow-hotplug wlan0/;s/#iface wlan0 inet dhcp/iface wlan0 inet dhcp/;s/#auto wlan0/auto wlan0/;s/#pre-up wpa_supplicant/pre-up wpa_supplicant/;s/#post-down killall -q wpa_supplicant/post-down killall -q wpa_supplicant/" /etc/network/interfaces  
			gui_connect_wifi			
		fi
	fi
}
