#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="retroarchinput"
rp_module_desc="Configure input devices for RetroArch"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function joystick_retroarchinput() {
    local configfname
    local numJoypads

    printMsgs "dialog" "Connect ONLY the controller to be registered for RetroArch to the Raspberry Pi."
    clear
    # todo Find number of first joystick device in /dev/input
    numJoypads=$(ls -1 /dev/input/js* | head -n 1)
    if [[ -n "$numJoypads" ]]; then
        "$emudir/retroarch/retroarch-joyconfig" --autoconfig "$emudir/retroarch/configs/tempconfig.cfg" --timeout 4 --joypad ${numJoypads:13}
        configfname=$(grep "input_device = \"" "$emudir/retroarch/configs/tempconfig.cfg")
        configfname=$(echo ${configfname:16:-1} | tr -d ' ')
        mv "$emudir/retroarch/configs/tempconfig.cfg" "$emudir/retroarch/configs/$configfname.cfg"

        # Add hotkeys
        rp_callModule retroarchautoconf remap_hotkeys "$emudir/retroarch/configs/$configfname.cfg"

        chown $user:$user "$emudir/retroarch/configs/$configfname.cfg"

        printMsgs "dialog" "The configuration file has been saved as $configfname.cfg and will be used by RetroArch from now on whenever that controller is connected."
    else
        printMsgs "dialog" "Sorry, no joystick detected."
    fi
}

function keyboard_retroarchinput() {
    if [[ ! -f "$configdir/all/retroarch.cfg" ]]; then
        printMsgs "dialog" "No RetroArch configuration file found at $configdir/all/retroarch.cfg"
        return
    fi
    local input
    local options
    local i=1
    local key=()
    while read input; do
        local parts=($input)
        key+=("${parts[0]}")
        options+=("${parts[0]}" $i 2 "${parts[*]:2}" $i 26 16 0)
        ((i++))
    done < <(grep "^[[:space:]]*input_player[0-9]_[a-z]*" "$configdir/all/retroarch.cfg")
    local cmd=(dialog --backtitle "$__backtitle" --form "RetroArch keyboard configuration" 22 48 16)
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        local value
        local values
        readarray -t values <<<"$choices"
        iniConfig " = " "" "$configdir/all/retroarch.cfg"
        i=0
        for value in "${values[@]}"; do
            iniSet "${key[$i]}" "$value" >/dev/null
            ((i++))
        done
    fi
}

function configure_retroarchinput() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose which input device to configure." 22 76 16)
    local options=(
        1 "Configure joystick/controller for use with RetroArch"
        2 "Configure keyboard for use with RetroArch"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case $choice in
            1)
                joystick_retroarchinput
                ;;
            2)
                keyboard_retroarchinput
                ;;
        esac
    fi
}