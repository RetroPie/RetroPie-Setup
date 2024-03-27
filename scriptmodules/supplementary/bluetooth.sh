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
    local mode="$(_get_connect_mode)"
    # if user has set bluetooth connect mode to boot or background, make sure we
    # have the latest dependencies and update systemd script
    if [[ "$mode" != "default" ]]; then
        # make sure dependencies are up to date
        ! hasPackage "bluez-tools" && depends_bluetooth
        connect_mode_set_bluetooth "$mode"
    fi
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
    local depends=(bluetooth python3-dbus python3-gi bluez-tools)
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

function _slowecho_bluetooth() {
    local line

    IFS=$'\n'
    for line in $(echo -e "${1}"); do
        echo -e "$line"
        sleep 1
    done
    unset IFS
}

function bluez_cmd_bluetooth() {
    # create a named pipe & fd for input for bluetoothctl
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    while true; do
        _slowecho_bluetooth "$1" >&3
        # collect output for specified amount of time, then echo it
        while read -r line; do
            printf '%s\n' "$line"
            # (slow) reply to any optional challenges
            if [[ -n "$3" && "$line" =~ $3 ]]; then
                _slowecho_bluetooth "$4" >&3
            fi
        done
        _slowecho_bluetooth "quit\n" >&3
        break
    # read from bluetoothctl buffered line by line
    done < <(timeout "$2" stdbuf -oL bluetoothctl --agent=NoInputNoOutput <&3)
    exec 3>&-
}

function list_available_bluetooth() {
    local mac
    local name
    local info_text="\n\nSearching ..."

    declare -A paired=()
    declare -A found=()

    # get an asc array of paired mac addresses
    while read mac; read name; do
        paired+=(["$mac"]="$name")
    done < <(list_paired_bluetooth)

    # sixaxis: add USB pairing information
    [[ -n "$(lsmod | grep hid_sony)" ]] && info_text="Searching ...\n\nDualShock registration: while this text is visible, unplug the controller, press the PS/SHARE button, and then replug the controller."
    # sixaxis: configure workaround for PS3 when we detect one
    if cat /proc/bus/input/devices | grep Name | grep -qE "(Sony )?PLAY.*3" ; then
        _bonded_fix_bluetooth "add"
        systemctl -q is-active bluetooth.service && systemctl restart bluetooth.service
    fi

    dialog --backtitle "$__backtitle" --infobox "$info_text" 7 60 >/dev/tty
    if hasPackage bluez 5; then
        # sixaxis: reply to authorization challenge on USB cable connect
        while read mac; read name; do
            found+=(["$mac"]="$name")
       done < <(bluez_cmd_bluetooth "default-agent\nscan on" "15" "Authorize service$" "yes" >/dev/null; bluez_cmd_bluetooth "devices" "3" | grep "^Device " | cut -d" " -f2,3- | sed 's/ /\n/')
    else
        while read; read mac; read name; do
            found+=(["$mac"]="$name")
        done < <(hcitool scan --flush | tail -n +2 | sed 's/\t/\n/g')
    fi

    # display any found addresses that are not already paired
    for mac in "${!found[@]}"; do
        if [[ -z "${paired[$mac]}" ]]; then
            echo "$mac"
            echo "${found[$mac]}"
        fi
    done
}

function list_registered_bluetooth() {
    local line
    while read line; do
        if [[ "$line" =~ ^(.+)\ \((.+)\)$ ]]; then
            echo ${BASH_REMATCH[2]}
            echo ${BASH_REMATCH[1]}
        fi
    done < <(bt-device --list 2>/dev/null)
}

function _devices_grep_bluetooth() {
    declare -A devices=()
    local pattern="$1"

    local mac
    local name
    while read mac; read name; do
        if bt-device --info "$mac" 2>/dev/null | grep -q "$pattern"; then
            echo "$mac"
            echo "$name"
        fi
    done < <(list_registered_bluetooth)
}

function list_paired_bluetooth() {
    _devices_grep_bluetooth "Paired: 1"
}

function list_connected_bluetooth() {
    _devices_grep_bluetooth "Connected: 1"
}

function status_bluetooth() {
    local paired
    local connected

    local mac
    local name

    while read mac; read name; do
        paired+="$mac - $name\n"
    done < <(list_paired_bluetooth)
    [[ -z "$paired" ]] && paired="There are no paired devices"

    while read mac; read name; do
        connected+="$mac - $name\n"
    done < <(list_connected_bluetooth)
    [[ -z "$connected" ]] && connected="There are no connected devices"

    echo -e "Paired Devices:\n\n$paired\nConnected Devices:\n\n$connected"
}

function remove_device_bluetooth() {
    declare -A devices=()
    local mac
    local name

    local options=()

    # show paired devices first
    while read mac; read name; do
        devices+=(["$mac"]="$name")
        options+=("$mac" "$name")
    done < <(list_paired_bluetooth)

    # then list all other devices known
    while read mac; read name; do
        if [[ -z "${devices[$mac]}" ]]; then
            devices+=(["$mac"]="$name")
            options+=("$mac" "$name")
        fi
    done < <(list_registered_bluetooth)

    if [[ ${#devices[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no devices to remove."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to remove" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return

        local out
        out=$(bt-device --remove "$choice" 2>&1)
        if [[ "$?" -eq 0 ]] ; then
            printMsgs "dialog" "Device ${devices[$choice]} removed"
            # remove Bluez workaround if it's the last PS3 device
            if [[ "${devices[$choice]}" == *PLAY*3* ]]; then
                list_paired_bluetooth | grep -qE "(Sony )?PLAY.*3"
                [[ ! $? -eq 0 ]] && _bonded_fix_bluetooth "remove"
            fi
        else
            printMsgs "dialog" "Error removing device:\n\n$out"
        fi
    fi
}

function pair_bluetooth() {
    declare -A devices=()
    local mac
    local name
    local options=()

    while read mac; read name; do
        devices+=(["$mac"]="$name")
        options+=("$mac" "$name")
    done < <(list_available_bluetooth)

    if [[ ${#devices[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No devices were found. Ensure device is on and try again"
        return
    fi

    local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to connect to" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    mac="$choice"
    name="${devices[$choice]}"

    if [[ "$name" =~ "PLAYSTATION(R)3 Controller" ]]; then
        bt-device --disconnect="$mac" >/dev/null
        bt-device --set "$mac" Trusted 1 >/dev/null
        if [[ "$?" -eq 0 ]]; then
            printMsgs "dialog" "Successfully authenticated $name ($mac).\n\nYou can now remove the USB cable."
        else
            printMsgs "dialog" "Unable to authenticate $name ($mac).\n\nPlease try to pair the device again, making sure to follow the on-screen steps exactly."
        fi
        return
    fi

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
    done < <(stdbuf -oL $(get_script_bluetooth bluez-simple-agent) -c "$mode" hci0 "$mac" <&3)
    exec 3>&-
    rm -f "$fifo"

    if [[ "$skip_connect" -eq 1 ]]; then
        if hcitool con | grep -q "$mac"; then
            printMsgs "dialog" "Successfully paired and connected to $mac"
            return 0
        else
            printMsgs "dialog" "Unable to connect to bluetooth device. Please try pairing with the commandline tool 'bluetoothctl'"
            return 1
        fi
    fi

    if [[ -z "$error" ]]; then
        error=$(bt-device --set "$mac" Trusted 1 2>&1)
        if [[ "$?" -eq 0 ]] ; then
            return 0
        fi
    fi

    printMsgs "dialog" "An error occurred connecting to the bluetooth device ($error)"
    return 1
}

function udev_bluetooth() {
    declare -A devices=()
    local mac
    local name
    local options=()
    while read mac; read name; do
        devices+=(["$mac"]="$name")
        options+=("$mac" "$name")
    done < <(list_paired_bluetooth)

    if [[ ${#devices[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no paired bluetooth devices."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the bluetooth device you would like to create a udev rule for" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return
        name="${devices[$choice]}"
        local config="/etc/udev/rules.d/99-bluetooth.rules"
        if ! grep -q "$name" "$config"; then
            local line="SUBSYSTEM==\"input\", ATTRS{name}==\"$name\", MODE=\"0666\", ENV{ID_INPUT_JOYSTICK}=\"1\""
            addLineToFile "$line" "$config"
            printMsgs "dialog" "Added $line to $config\n\nPlease reboot for the configuration to take effect."
        else
            printMsgs "dialog" "An entry already exists for $name in $config"
        fi
    fi
}

function connect_bluetooth() {
    local mac
    local name
    while read mac; read name; do
        bt-device --connect "$mac" 2>/dev/null
    done < <(list_paired_bluetooth)
}

function connect_mode_gui_bluetooth() {
    local mode="$(_get_connect_mode)"
    [[ -z "$mode" ]] && mode="default"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$mode" --menu "Choose a connect mode" 22 76 16)

    local options=(
        default "Bluetooth stack default behaviour (recommended)"
        boot "Connect to devices once at boot"
        background "Force connecting to devices in the background"
    )

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && connect_mode_set_bluetooth "$choice"
}

function connect_mode_set_bluetooth() {
    local mode="$1"
    [[ -z "$mode" ]] && mode="default"

    local config="/etc/systemd/system/connect-bluetooth.service"
    case "$mode" in
        boot|background)
            mkdir -p "$md_inst"
            sed -e "s#CONFIGDIR#$configdir#" -e "s#ROOTDIR#$rootdir#" "$md_data/connect.sh" >"$md_inst/connect.sh"
            chmod a+x "$md_inst/connect.sh"
            cat > "$config" << _EOF_
[Unit]
Description=Connect Bluetooth

[Service]
Type=simple
ExecStart=nice -n19 "$md_inst/connect.sh"

[Install]
WantedBy=multi-user.target
_EOF_
            systemctl enable "$config"
            ;;
        default)
            if systemctl is-enabled connect-bluetooth 2>/dev/null | grep -q "enabled"; then
               systemctl disable "$config"
            fi
            rm -f "$config"
            rm -rf "$md_inst"
            ;;
    esac
    iniConfig "=" '"' "$configdir/all/bluetooth.cfg"
    iniSet "connect_mode" "$mode"
    chown $user:$user "$configdir/all/bluetooth.cfg"
}

function gui_bluetooth() {
    addAutoConf "8bitdo_hack" 0

    while true; do
        local connect_mode="$(_get_connect_mode)"

        local cmd=(dialog --backtitle "$__backtitle" --menu "Configure Bluetooth Devices" 22 76 16)
        local options=(
            P "Pair and Connect to Bluetooth Device"
            X "Remove Bluetooth Device"
            S "Show Paired & Connected Bluetooth Devices"
            U "Set up udev rule for Joypad (required for joypads from 8Bitdo etc)"
            C "Connect now to all paired devices"
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
            service sixad status &>/dev/null && sixad -r
            case "$choice" in
                P)
                    pair_bluetooth
                    ;;
                X)
                    remove_device_bluetooth
                    ;;
                S)
                    printMsgs "dialog" "$(status_bluetooth)"
                    ;;
                U)
                    udev_bluetooth
                    ;;
                C)
                    connect_bluetooth
                    ;;
                M)
                    connect_mode_gui_bluetooth
                    ;;
                8)
                    atebitdo="$((atebitdo ^ 1))"
                    setAutoConf "8bitdo_hack" "$atebitdo"
                    ;;
            esac
        else
            # restart sixad (if running)
            service sixad status &>/dev/null && service sixad restart && printMsgs "dialog" "NOTICE: The ps3controller driver was temporarily interrupted in order to allow compatibility with standard Bluetooth peripherals. Please re-pair your Dual Shock controller to continue (or disregard this message if currently using another controller)."
            break
        fi
    done
}

function _bonded_fix_bluetooth() {
    local mode=$1
    # exit when we don't have an op mode (install/remove) or a config file
    [[ -z "$mode" ]] && return
    [[ ! -f "/etc/bluetooth/input.conf" ]] && return

    if [[ "$mode" == "add" ]]; then
        # configure the workaround
        iniConfig "=" '' "/etc/bluetooth/input.conf"
        iniSet "ClassicBondedOnly" "false"
    fi

    if [[ "$mode" == "remove" ]]; then
        # remove the workaround
        iniConfig "=" '' "/etc/bluetooth/input.conf"
        iniSet "ClassicBondedOnly" "true"
    fi
}
