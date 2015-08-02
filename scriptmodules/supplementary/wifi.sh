#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wifi"
rp_module_desc="Configure Wifi"
rp_module_menus="3+"
rp_module_flags="nobin"

function wifi_list() {
    ifconfig wlan0 up
    wifiNetworkList=$(iwlist wlan0 scan | grep ESSID | awk -F \" '{print $2}')
    printMsgs "dialog" "$wifiNetworkList"
}

function wifi_wpa() {
    ifconfig wlan0 up
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please Enter the SSID of the Network You Would Like to Connect to:" 10 60 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi

    cmd=(dialog --backtitle "$__backtitle" --insecure --passwordbox "Please enter the network password" 10 60 $psk)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        psk="$choice"
    fi

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tpsk="'$psk'"\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    ifdown wlan0
    ifup wlan0
    printMsgs "dialog" "You are now connected to: $ssid\n\nConfigurations have been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"
}

function wifi_wep() {
    ifconfig wlan0 up
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please Enter the SSID of the Network You Would Like to Connect to" 10 60 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi

    cmd=(dialog --backtitle "$__backtitle" --insecure --passwordbox "Please Enter Your WEP Key" 10 60 $psk)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        psk="$choice"
    fi

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tkey_mgmt=NONE\n\twep_tx_keyidx=0\n\tpsk='"$psk"'\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    ifdown wlan0
    ifup wlan0
    printMsgs "dialog" "You are now connected to: $ssid\n\nConfigurations have been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"
}

function wifi_open() {
    ifconfig wlan0 up
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please Enter the SSID of the Network You Would Like to Connect to" 10 60 "$ssid")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        ssid="$choice"
    fi

    echo -e 'auto lo\n\niface lo inet loopback\niface eth0 inet dhcp\n\nallow-hotplug wlan0\nauto wlan0\n\niface wlan0 inet manual\nwpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n\niface default inet dhcp' > "/etc/network/interfaces"

    echo -e 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\n\nnetwork={\n\tssid="'$ssid'"\n\tkey_mgmt=NONE\n}' > "/etc/wpa_supplicant/wpa_supplicant.conf"
    ifdown wlan0
    ifup wlan0
    printMsgs "dialog" "You are now connected to: $ssid\n\nConfigurations have been saved to /etc/network/interfaces and /etc/wpa_supplicant/wpa_supplicant.conf"
}

function configure_wifi() {

    local ip_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure Wifi.\nCurrent IP: $ip_int" 22 76 16)
        options=(
            1 "Show List of available Wifi Networks"
            2 "Connect to WPA/WPA2 Wifi Network. (Most Networks)"
            3 "Connect to WEP Wifi Network."
            4 "Connect to Open Wifi Network."
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    wifi_list
                    ;;
                2)
                    wifi_wpa
                    ;;
                3)
                    wifi_wep
                    ;;
                4)
                    wifi_open
                    ;;
            esac
        else
            break
        fi
    done
}
