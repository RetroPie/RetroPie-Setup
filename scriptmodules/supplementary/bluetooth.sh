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
rp_module_desc="Configure Bluetooth devices"
rp_module_section="config"

function _is_keyboard_attached_bluetooth() {
    grep -qP --regexp='(?s)(?<=^H: Handlers=).*\bkbd(?=\b)' /proc/bus/input/devices
    return $?
}

function _is_joystick_attached_bluetooth() {
    grep -qP --regexp='(?s)(?<=^H: Handlers=).*\bjs[0-9]+(?=\b)' /proc/bus/input/devices
}

function _update_hook_bluetooth() {
    # fix config location
    [[ -f "$configdir/bluetooth.cfg" ]] && mv "$configdir/bluetooth.cfg" "$configdir/all/bluetooth.cfg"
    local mode="$(_get_connect_mode_bluetooth)"
    # if user has set bluetooth connect mode to boot or background, make sure we
    # have the latest dependencies and update systemd script
    if [[ "$mode" != "default" ]]; then
        # make sure dependencies are up to date
        ! hasPackage "bluez-tools" && depends_bluetooth
        connect_mode_set_bluetooth "$mode"
    fi
}

function _get_connect_mode_bluetooth() {
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
    local depends=(bluetooth python-dbus python-gobject bluez-tools)
    if [[ "$__os_id" == "Raspbian" ]]; then
        depends+=(pi-bluetooth raspberrypi-sys-mods)
    fi
    getDepends "${depends[@]}"
}

function _bluetoothctl_slowecho_bluetooth() {
    local line
    
    IFS=$'\n'
    for line in $(echo -e "${1}"); do
        echo -e "$line"
        sleep 1
    done
    unset IFS
}

function bluetoothctl_cmd_bluetooth() {
    # create a named pipe & fd for input for bluetoothctl
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    while true; do
        _bluetoothctl_slowecho_bluetooth "$1" >&3
        # collect output for specified amount of time, then echo it
        while read -r line; do
            printf '%s\n' "$line"
            # (slow) reply to any optional challenges
            if [[ -n "$3" && "$line" =~ $3 ]]; then
                _bluetoothctl_slowecho_bluetooth "$4" >&3
            fi
        done
        _bluetoothctl_slowecho_bluetooth "quit\n" >&3
        break
    # read from bluetoothctl buffered line by line
    done < <(timeout "$2" stdbuf -oL bluetoothctl --agent=NoInputNoOutput <&3)
    exec 3>&-
}

function _raw_list_known_devices_with_regex_bluetooth() {
    local regex="$1"
    while read line; do
        local mac="$(echo "$line" | grep --color=none -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
        if [[ -n "$mac" ]]; then
            # suppress stderr due to segfault bug in bluez 5.50
            local info; info="$(bt-device --info $mac 2>/dev/null)"
            if [[ "$?" == "0" ]] ; then
                if echo "$info" | grep -qzP --regex="$regex"; then
                    echo "$line"
                fi
            fi
        fi
    done < <(bt-device --list)
}

function _list_paired_devices_bluetooth() {
    local line
    while read line; do
        if [[ "$line" =~ ^(.+)\ \((.+)\)$ ]]; then
            echo "${BASH_REMATCH[2]}"
            echo "${BASH_REMATCH[1]}"
        fi
    done < <(_raw_list_known_devices_with_regex_bluetooth '(?s)^(?=.*\bPaired: 1\b).*$')
}

function _list_connected_devices_bluetooth() {
    local line
    while read line; do
        if [[ "$line" =~ ^(.+)\ \((.+)\)$ ]]; then
            echo "${BASH_REMATCH[2]}"
            echo "${BASH_REMATCH[1]}"
        fi
    done < <(_raw_list_known_devices_with_regex_bluetooth '(?s)^(?=.*\bPaired: 1\b)(?=.*\bConnected: 1\b).*$')
}

function _list_disconnected_devices_bluetooth() {
    local line
    while read line; do
        if [[ "$line" =~ ^(.+)\ \((.+)\)$ ]]; then
            echo "${BASH_REMATCH[2]}"
            echo "${BASH_REMATCH[1]}"
        fi
    done < <(_raw_list_known_devices_with_regex_bluetooth '(?s)^(?=.*\bPaired: 1\b)(?=.*\bConnected: 0\b).*$')
}

function list_unpaired_devices_bluetooth() {
    local mac_address
    local device_name
    local info_text="Scanning for devices..."

    declare -A paired=()
    declare -A found=()

    # get an asc array of paired mac addresses
    while read mac_address; read device_name; do
        paired+=(["$mac_address"]="$device_name")
    done < <(_list_paired_devices_bluetooth)

    # sixaxis: add USB pairing information
    [[ -n "$(lsmod | grep hid_sony)" ]] && info_text="$info_text\n\nDualShock registration: while this text is visible, unplug the controller, press the PS/SHARE button, and then replug the controller."

    printMsgs "info" "$info_text"
    if hasPackage bluez 5; then
        # sixaxis: reply to authorization challenge on USB cable connect
        while read mac_address; read device_name; do
            found+=(["$mac_address"]="$device_name")
        done < <(bluetoothctl_cmd_bluetooth "default-agent\nscan on" "15" "Authorize service$" "yes" >/dev/null; bluetoothctl_cmd_bluetooth "devices" "3" | grep "^Device " | cut -d" " -f2,3- | sed 's/ /\n/')
    else
        while read; read mac_address; read device_name; do
            found+=(["$mac_address"]="$device_name")
        done < <(hcitool scan --flush | tail -n +2 | sed 's/\t/\n/g')
    fi

    # display any found devices that are not already paired
    for mac_address in "${!found[@]}"; do
        if [[ -z "${paired[$mac_address]}" ]]; then
            echo "$mac_address"
            echo "${found[$mac_address]}"
        fi
    done
}

function display_all_paired_devices_bluetooth() {
    printMsgs "info" "Working..."

    local mac_address
    local device_name
    local connected=''
    while read mac_address; read device_name; do
        connected="$connected  $mac_address  $device_name\n"
    done < <(_list_connected_devices_bluetooth)
    [[ -z "$connected" ]] && connected="  <none>\n"

    local disconnected=''
    while read mac_address; read device_name; do
        disconnected="$disconnected  $mac_address  $device_name\n"
    done < <(_list_disconnected_devices_bluetooth)
    [[ -z "$disconnected" ]] && disconnected="  <none>\n"

    printMsgs "dialog" "Connected Devices:\n\n$connected\nDisconnected Devices:\n\n$disconnected"
}

function remove_paired_device_bluetooth() {
    declare -A mac_addresses=()
    local mac_address
    local device_name
    local options=()
    while read mac_address; read device_name; do
        mac_addresses+=(["$mac_address"]="$device_name")
        options+=("$mac_address" "$device_name")
    done < <(_list_paired_devices_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no devices to remove."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Which Bluetooth device do you want to remove?" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return

    	printMsgs "info" "Removing..."
        local out=$(bt-device --remove $choice 2>&1)
        if [[ "$?" -eq 0 ]] ; then
            printMsgs "dialog" "Device removed successfully."
        else
            printMsgs "dialog" "Error removing device:\n\n$out"
        fi
    fi
}

function pair_device_bluetooth() {
    declare -A mac_addresses=()
    local mac_address
    local device_name
    local options=()

    while read mac_address; read device_name; do
        mac_addresses+=(["$mac_address"]="$device_name")
        options+=("$mac_address" "$device_name")
    done < <(list_unpaired_devices_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No devices were found. Ensure your device is on, and try again."
        return
    fi

    local cmd=(dialog --backtitle "$__backtitle" --menu "Which Bluetooth device do you want to pair?" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    mac_address="$choice"
    device_name="${mac_addresses[$choice]}"

    printMsgs "info" "Pairing..."

    if [[ "$device_name" =~ "PLAYSTATION(R)3 Controller" ]]; then
        bt-device --disconnect="$mac_address" >/dev/null
        bt-device --set "$mac_address" Trusted 1 >/dev/null
        if [[ "$?" -eq 0 ]]; then
            printMsgs "dialog" "Successfully authenticated $device_name ($mac_address).\n\nYou can now remove the USB cable."
        else
            printMsgs "dialog" "Unable to authenticate $device_name ($mac_address).\n\nPlease try to pair the device again, making sure to follow the on-screen steps exactly."
        fi
        return
    fi

    if _is_keyboard_attached_bluetooth; then
        local capability='KeyboardDisplay'
    elif _is_joystick_attached_bluetooth; then
        local capability='DisplayYesNo'
    else
        local capability='DisplayOnly'
    fi

    # create a named pipe & fd for input for pair-device
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    local pin
    local passkey
    local succeeded=''
    local error=""
    while read -r line; do
        case "$line" in
            "RequestPinCode"*)
                cmd=(dialog --nocancel --backtitle "$__backtitle" --menu "Which PIN do you want to use?" 22 76 16)
                options=(
                    1 "Pin 0000"
                    2 "Enter own Pin"
                )
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                pin="0000"
                if [[ "$choice" == "2" ]]; then
                    pin=$(dialog --backtitle "$__backtitle" --inputbox "Please enter a pin" 10 60 2>&1 >/dev/tty)
                fi
                dialog --backtitle "$__backtitle" --infobox "Please enter PIN $pin (and press ENTER) on your Bluetooth device now." 10 60
                echo "$pin" >&3
                # read "Enter PIN Code:"
                read -n 15 line
                ;;
            "RequestConfirmation"*)
                # read "Confirm passkey (yes/no): "
                echo "yes" >&3
                read -n 26 line
                break
                ;;
            "DisplayPasskey"*|"DisplayPinCode"*)
                # extract key from end of line
                [[ "$line" =~ ,\ (.+)\) ]] && passkey=${BASH_REMATCH[1]}
                dialog --backtitle "$__backtitle" --infobox "Please enter passkey $passkey (and press ENTER) on your Bluetooth device now." 10 60
                ;;
            "Creating device failed"*)
                error="$line"
                ;;
            "Done.")
                succeeded='1'
                ;;
        esac
    # read from pair-device buffered line by line
    done < <(stdbuf -oL "$md_data/pair-device" -c "$capability" -i hci0 "$mac_address" <&3)
    exec 3>&-
    rm -f "$fifo"

    if [[ -n "$error" ]]; then
        printMsgs "dialog" "An error occurred while pairing and connecting to $mac_address $device_name:\n\n$error"
        return 1
    elif [[ "$succeeded" == '1' ]]; then
        printMsgs "dialog" "Successfully paired and connected to $mac_address $device_name."
        return 0
    else
        printMsgs "dialog" "Unable to connect to $mac_address $device_name. Please try pairing with the commandline tool 'bluetoothctl' instead."
        return 1
    fi
}

function setup_joypad_udev_rule_bluetooth() {
    declare -A mac_addresses=()
    local mac_address
    local device_name
    local options=()
    while read mac_address; read device_name; do
        mac_addresses+=(["$mac_address"]="$device_name")
        options+=("$mac_address" "$device_name")
    done < <(_list_paired_devices_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no paired bluetooth devices."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Which Bluetooth device do you want to set up a udev rule for?" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return
        device_name="${mac_addresses[$choice]}"
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

function connect_all_disconnected_devices_bluetooth() {
    printMsgs "info" "Working..."
    local devices="$(_list_disconnected_devices_bluetooth)"
    if [[ -z "$devices" ]]; then
        printMsgs "dialog" "All devices are already connected."
        return 0
    fi

    local mac_address
    local device_name
    local connected=''
    local errored=''
    while read mac_address; read device_name; do
        printMsgs "info" "Connecting to $mac_address $device_name..."
        local output
        output="$(bt-device --connect "$mac_address" 2>&1)"
        if [[ "$?" != "0" ]]; then
            errored="$errored  $mac_address  $device_name\n"
            printMsgs "dialog" "Error while connecting to $mac_address $device_name:\n\n$output"
        else
            connected="$connected  $mac_address  $device_name\n"
        fi
    done < <(echo "$devices")

    local msg=''
    if [[ -n "$connected" ]]; then
        msg="Connected successfully:\n\n$connected"
    fi
    if [[ -n "$errored" ]]; then
        msg="Connection failed:\n\n$errored"
    fi
    printMsgs "dialog" "$msg"
}

function connect_mode_gui_bluetooth() {
    local mode="$(_get_connect_mode_bluetooth)"
    [[ -z "$mode" ]] && mode="default"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$mode" --menu "Which Bluetooth connection mode do you want to use?" 22 76 16)

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
        local connect_mode="$(_get_connect_mode_bluetooth)"

        local cmd=(dialog --backtitle "$__backtitle" --menu "Configure Bluetooth Devices" 22 76 16)
        local options=(
            P "Pair a Bluetooth device"
            C "Connect all disconnected Bluetooth devices"
            D "Display all paired Bluetooth devices"
            X "Remove a paired Bluetooth device"
            U "Set up udev rule for Bluetooth joypad (required for 8Bitdo, etc)"
            M "Change Bluetooth connect mode (currently: $connect_mode)"
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
                    pair_device_bluetooth
                    ;;
                X)
                    remove_paired_device_bluetooth
                    ;;
                D)
                    display_all_paired_devices_bluetooth
                    ;;
                U)
                    setup_joypad_udev_rule_bluetooth
                    ;;
                C)
                    connect_all_disconnected_devices_bluetooth
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
