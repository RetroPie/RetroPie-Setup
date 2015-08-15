#!/usr/bin/env bash

# This file is part of RetroPie.
#
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="bluetooth"
rp_module_desc="Configure Bluetooth Devices"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_bluetooth() {
    getDepends bluez-utils bluez-compat bluez-hcidump bluetooth
}

function list_available_bluetooth() {
    local mac_address
    local device_name
    while read; read mac_address; read device_name; do
        echo "$mac_address"
        echo "$device_name"
    done < <(hcitool scan --flush | tail -n +2 | sed 's/\t/\n/g')
}

function list_registered_bluetooth() {
    local line
    local mac_address
    local device_name
    while read line; do
        mac_address=$(echo $line | sed 's/ /,/g' | cut -d, -f1)
        device_name=$(echo $line | sed -e 's/'"$mac_address"' //g')
        echo -e "$mac_address\n$device_name"
    done < <(bluez-test-device list)
}

function display_active_and_registered_bluetooth() {
    local registered_devices="There are no registered devices"
    [[ "$(bluez-test-device list)" != "" ]] && registered_devices=$(bluez-test-device list)
    local active_connections="There are no active connections"
    [[ "$(hcitool con)" != "Connections:" ]] && active_connections=$(hcitool con | sed -e 1d)

    printMsgs "dialog" "Registered Devices:\n\n$registered_devices\n\n\nActive Connections:\n\n$active_connections"
}

function remove_bluetooth() {
    local mac_addresses=()
    local mac_address
    local device_names=()
    local device_name
    local options=()
    while read mac_address; read device_name; do
        mac_addresses+=("$mac_address")
        device_names+=("$device_name")
        options+=("$mac_address" "$device_name")
    done < <(list_registered_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no devices to remove."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to remove" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return

        remove_bluetooth_device=$(bluez-test-device remove $choice)
        if [[ -z "$remove_bluetooth_device" ]] ; then
            printMsgs "dialog" "Device removed"
        else
            printMsgs "dialog" "An error occurred removing the bluetooth device. Please ensure you typed the mac address correctly"
        fi
    fi
}

function connect_bluetooth() {
    local mac_addresses=()
    local mac_address
    local device_names=()
    local device_name
    local options=()
    while read mac_address; read device_name; do
        mac_addresses+=("$mac_address")
        device_names+=("$device_name")
        options+=("$mac_address" "$device_name")
    done < <(list_available_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No devices were found. Ensure device is on and try again"
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to connect to" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return

        exec 5>&1
        local ret
        ret=$(bluez-simple-agent hci0 "$choice" >&5)
        if [[ -z "$ret" ]] || [[ "$ret" != "Creating device filed: org.bluez.Error.AlreadyExists: Already Exists" ]] ; then
            ret=$(bluez-test-device trusted "$choice" yes >&5)
            if [[ -z "$ret" ]] ; then
                ret=$(bluez-test-input connect "$choice" >&5)
                if [[ -z "$ret" ]]; then
                    printMsgs "dialog" "Bluetooth device has been connected"
                fi
            fi
        fi

        if ! [[ -z "$ret" ]] ; then
            printMsgs "dialog" "An error occurred connecting to the bluetooth device"
        fi
    fi
}

function configure_bluetooth() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Configure Bluetooth Devices" 22 76 16)
        local options=(
            1 "Connect to Bluetooth Device"
            2 "Remove Bluetooth Device"
            3 "Display Registered & Connected Bluetooth Devices"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    connect_bluetooth
                    ;;
                2)
                    remove_bluetooth
                    ;;
                3)
                    display_active_and_registered_bluetooth
                    ;;
            esac
        else
            break
        fi
    done
}
