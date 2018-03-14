#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="bluetooth"
rp_module_desc="Configure Bluetooth Devices"
rp_module_section="config"

function _update_hook_bluetooth() {
    # fix config location
    [[ -f "$configdir/bluetooth.cfg" ]] && mv "$configdir/bluetooth.cfg" "$configdir/all/bluetooth.cfg"
}

function _get_connect_mode() {
    # get bluetooth config
    iniConfig "=" '"' "$configdir/all/bluetooth.cfg"
    iniGet "connect_mode"
    if [[ -n "$ini_value" ]]; then
        echo "$ini_value"
    else
        echo "default"
    fi
}

function depends_bluetooth() {
    local depends=(bluetooth python-dbus python-gobject)
    if [[ "$__os_id" == "Raspbian" ]]; then
        depends+=(pi-bluetooth raspberrypi-sys-mods)
    fi
    getDepends "${depends[@]}"
}

function get_script_bluetooth() {
    name="$1"
    if ! which "$name"; then
        [[ "$name" == "bluez-test-input" ]] && name="bluez-test-device"
        name="$md_data/$name"
    fi
    echo "$name"
}

function bluez_cmd_bluetooth() {
    # create a named pipe & fd for input for bluetoothctl
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    while read -r line; do
        if [[ "$line" == *"[bluetooth]"* ]]; then
            echo -e "$1" >&3
            read -r line
            if [[ -n "$2" ]]; then
                # collect output for specified amount of time, then echo it
                local buf
                while read -r -t "$2" line; do
                    buf+=("$line")
                    # reply to any optional challenges
                    if [[ -n "$4" && "$line" == *"$3"* ]]; then
                        echo -e "$4" >&3
                    fi
                done
                printf '%s\n' "${buf[@]}"
            fi
            sleep 1
            echo -e "quit" >&3
            break
        fi
    # read from bluetoothctl buffered line by line
    done < <(stdbuf -oL bluetoothctl <&3)
    exec 3>&-
}

function list_available_bluetooth() {
    local mac_address
    local device_name

    dialog --backtitle "$__backtitle" --infobox "\nSearching ..." 5 40 >/dev/tty
    if hasPackage bluez 5; then
        while read mac_address; read device_name; do
            echo "$mac_address"
            echo "$device_name"
        done < <(bluez_cmd_bluetooth "scan on" "10" >/dev/null; bluez_cmd_bluetooth "devices" "2" | grep "^Device " | cut -d" " -f2,3- | sed 's/ /\n/')
    else
        while read; read mac_address; read device_name; do
            echo "$mac_address"
            echo "$device_name"
        done < <(hcitool scan --flush | tail -n +2 | sed 's/\t/\n/g')
    fi
}

function list_registered_bluetooth() {
    local line
    local mac_address
    local device_name
    while read line; do
        mac_address="$(echo "$line" | sed 's/ /,/g' | cut -d, -f1)"
        device_name="$(echo "$line" | sed 's/'"$mac_address"' //g')"
        echo -e "$mac_address\n$device_name"
    done < <($(get_script_bluetooth bluez-test-device) list)
}

function display_active_and_registered_bluetooth() {
    local registered
    local active

    registered="$($(get_script_bluetooth bluez-test-device) list 2>&1)"
    [[ -z "$registered" ]] && registered="There are no registered devices"

    if [[ "$(hcitool con)" != "Connections:" ]]; then
        active="$(hcitool con 2>&1 | sed 1d)"
    else
        active="There are no active connections"
    fi

    printMsgs "dialog" "Registered Devices:\n\n$registered\n\n\nActive Connections:\n\n$active"
}

function remove_device_bluetooth() {
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

        remove_bluetooth_device=$($(get_script_bluetooth bluez-test-device) remove $choice)
        if [[ -z "$remove_bluetooth_device" ]] ; then
            printMsgs "dialog" "Device removed"
        else
            printMsgs "dialog" "An error occurred removing the bluetooth device. Please ensure you typed the mac address correctly"
        fi
    fi
}

function register_bluetooth() {
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
        return
    fi

    local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to connect to" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    mac_address="$choice"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the security mode - Try the first one, then second if that fails" 22 76 16)
    options=(
        1 "DisplayYesNo"
        2 "KeyboardDisplay"
        3 "NoInputNoOutput"
        4 "DisplayOnly"
        5 "KeyboardOnly"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local mode="${options[choice*2-1]}"

    # create a named pipe & fd for input for bluez-simple-agent
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    local pin
    local error=""
    local skip_connect=0
    while read -r line; do
        case "$line" in
            "RequestPinCode"*)
                cmd=(dialog --nocancel --backtitle "$__backtitle" --menu "Please choose a pin" 22 76 16)
                options=(
                    1 "Pin 0000"
                    2 "Enter own Pin"
                )
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                pin="0000"
                if [[ "$choice" == "2" ]]; then
                    pin=$(dialog --backtitle "$__backtitle" --inputbox "Please enter a pin" 10 60 2>&1 >/dev/tty)
                fi
                dialog --backtitle "$__backtitle" --infobox "Please enter pin $pin on your bluetooth device" 10 60
                echo "$pin" >&3
                # read "Enter PIN Code:"
                read -n 15 line
                ;;
            "RequestConfirmation"*)
                # read "Confirm passkey (yes/no): "
                echo "yes" >&3
                read -n 26 line
                skip_connect=1
                break
                ;;
            "DisplayPasskey"*|"DisplayPinCode"*)
                # extract key from end of line
                # DisplayPasskey (/org/bluez/1284/hci0/dev_01_02_03_04_05_06, 123456)
                [[ "$line" =~ ,\ (.+)\) ]] && pin=${BASH_REMATCH[1]}
                dialog --backtitle "$__backtitle" --infobox "Please enter pin $pin on your bluetooth device" 10 60
                ;;
            "Creating device failed"*)
                error="$line"
                ;;
        esac
    # read from bluez-simple-agent buffered line by line
    done < <(stdbuf -oL $(get_script_bluetooth bluez-simple-agent) -c "$mode" hci0 "$mac_address" <&3)
    exec 3>&-
    rm -f "$fifo"

    if [[ "$skip_connect" -eq 1 ]]; then
        if hcitool con | grep -q "$mac_address"; then
            printMsgs "dialog" "Successfully registered and connected to $mac_address"
            return 0
        else
            printMsgs "dialog" "Unable to connect to bluetooth device. Please try pairing with the commandline tool 'bluetoothctl'"
            return 1
        fi
    fi

    if [[ -z "$error" ]]; then
        error=$($(get_script_bluetooth bluez-test-device) trusted "$mac_address" yes 2>&1)
        if [[ -z "$error" ]] ; then
            error=$($(get_script_bluetooth bluez-test-input) connect "$mac_address" 2>&1)
            if [[ -z "$error" ]]; then
                printMsgs "dialog" "Successfully registered and connected to $mac_address"
                return 0
            fi
        fi
    fi

    printMsgs "dialog" "An error occurred connecting to the bluetooth device ($error)"
    return 1
}

function udev_bluetooth() {
    local mac_addresses=()
    local mac_address
    local device_names=()
    local device_name
    local options=()
    local i=1
    while read mac_address; read device_name; do
        mac_addresses+=("$mac_address")
        device_names+=("$device_name")
        options+=("$i" "$device_name")
        ((i++))
    done < <(list_registered_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no registered bluetooth devices."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to create a udev rule for" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return
        device_name="${device_names[choice-1]}"
        local config="/etc/udev/rules.d/99-bluetooth.rules"
        if ! grep -q "$device_name" "$config"; then
            local line="SUBSYSTEM==\"input\", ATTRS{name}==\"$device_name\", MODE=\"0666\", ENV{ID_INPUT_JOYSTICK}=\"1\""
            addLineToFile "$line" "$config"
            printMsgs "dialog" "Added $line to $config\n\nPlease reboot for the configuration to take effect."
        else
            printMsgs "dialog" "An entry already exists for $device_name in $config"
        fi
    fi
}

function connect_bluetooth() {
    local mac_address
    local device_name
    while read mac_address; read device_name; do
        $($(get_script_bluetooth bluez-test-input) connect "$mac_address" 2>/dev/null)
    done < <(list_registered_bluetooth)
}

function boot_bluetooth() {
    connect_mode="$(_get_connect_mode)"
    case "$connect_mode" in
        boot)
            connect_bluetooth
            ;;
        background)
            local script=""
            local macs=()
            local mac_address
            local device_name
            while read mac_address; read device_name; do
                macs+=($mac_address)
            done < <(list_registered_bluetooth)
            local script="while true; do for mac in ${macs[@]}; do hcitool con | grep -q \"\$mac\" || { echo \"connect \$mac\nquit\"; sleep 1; } | bluetoothctl >/dev/null 2>&1; sleep 10; done; done"
            nohup nice -n19 /bin/sh -c "$script" >/dev/null &
            ;;
    esac
}

function connect_mode_bluetooth() {
    local connect_mode="$(_get_connect_mode)"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$connect_mode" --menu "Choose a connect mode" 22 76 16)

    local options=(
        default "Bluetooth stack default behaviour (recommended)"
        boot "Connect to devices once at boot"
        background "Force connecting to devices in the background"
    )

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local config="/etc/systemd/system/connect-bluetooth.service"
    case "$choice" in
        boot|background)
            local type="simple"
            [[ "$choice" == "background" ]] && type="forking"
            cat > "$config" << _EOF_
[Unit]
Description=Connect Bluetooth

[Service]
Type=$type
ExecStart=/bin/bash "$scriptdir/retropie_packages.sh" bluetooth boot

[Install]
WantedBy=multi-user.target
_EOF_
            systemctl enable "$config"
            ;;
        default)
            if systemctl is-enabled connect-bluetooth | grep -q "enabled"; then
               systemctl disable "$config"
            fi
            rm -f "$config"
            ;;
    esac
    iniConfig "=" '"' "$configdir/all/bluetooth.cfg"
    iniSet "connect_mode" "$choice"
    chown $user:$user "$configdir/all/bluetooth.cfg"
}

function gui_bluetooth() {
    addAutoConf "8bitdo_hack" 0

    while true; do
        local connect_mode="$(_get_connect_mode)"

        local cmd=(dialog --backtitle "$__backtitle" --menu "Configure Bluetooth Devices" 22 76 16)
        local options=(
            R "Register and Connect to Bluetooth Device"
            X "Remove Bluetooth Device"
            D "Display Registered & Connected Bluetooth Devices"
            U "Set up udev rule for Joypad (required for joypads from 8Bitdo etc)"
            C "Connect now to all registered devices"
            M "Configure bluetooth connect mode (currently: $connect_mode)"
        )

        local atebitdo
        if getAutoConf 8bitdo_hack; then
            atebitdo=1
            options+=(8 "8Bitdo mapping hack (ON - old firmware)")
        else
            atebitdo=0
            options+=(8 "8Bitdo mapping hack (OFF - new firmware)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            # temporarily restore Bluetooth stack (if needed)
            service sixad status >/dev/null && sixad -r
            case "$choice" in
                R)
                    register_bluetooth
                    ;;
                X)
                    remove_device_bluetooth
                    ;;
                D)
                    display_active_and_registered_bluetooth
                    ;;
                U)
                    udev_bluetooth
                    ;;
                C)
                    connect_bluetooth
                    ;;
                M)
                    connect_mode_bluetooth
                    ;;
                8)
                    atebitdo="$((atebitdo ^ 1))"
                    setAutoConf "8bitdo_hack" "$atebitdo"
                    ;;
            esac
        else
            # restart sixad (if running)
            service sixad status >/dev/null && service sixad restart && printMsgs "dialog" "NOTICE: The ps3controller driver was temporarily interrupted in order to allow compatibility with standard Bluetooth peripherals. Please re-pair your Dual Shock controller to continue (or disregard this message if currently using another controller)."
            break
        fi
    done
}
