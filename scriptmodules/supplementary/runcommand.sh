#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="runcommand"
rp_module_desc="Configure the 'runcommand' - Launch script"
rp_module_menus="3+gui"
rp_module_flags="nobin"

function depends_runcommand() {
    getDepends python
}

function install_runcommand() {
    cp "$scriptdir/scriptmodules/$md_type/$md_id/runcommand.sh" "$md_inst/"
    cp "$scriptdir/scriptmodules/$md_type/$md_id/joy2key.py" "$md_inst/"
    chmod a+x "$md_inst/runcommand.sh"
    chmod a+x "$md_inst/joy2key.py"
    if [[ ! -f "$configdir/all/runcommand.cfg" ]]; then
        mkUserDir "$configdir/all"
        iniConfig "=" '"' "$configdir/all/runcommand.cfg"
        iniSet "use_art" "0"
        iniSet "disable_joystick" "0"
        iniSet "governor" ""
        chown $user:$user "$configdir/all/runcommand.cfg"
    fi
}

function governor_runcommand() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Configure CPU Governor on command launch" 22 86 16)
    local governors
    local governor
    local options=("1" "Default (don't change)")
    local i=2
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]]; then
        for governor in $(</sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors); do
            governors[$i]="$governor"
            options+=("$i" "Force $governor")
            ((i++))
        done
    fi
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        governor="${governors[$choices]}"
        iniSet "governor" "$governor"
        chown $user:$user "$configdir/all/runcommand.cfg"
    fi
}

function gui_runcommand() {
    iniConfig "=" '"' "$configdir/all/runcommand.cfg"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do

        local options=(
            1 "Configure CPU governor to use during emulation"
        )

        iniGet "use_art"
        local use_art="$ini_value"
        [[ "$use_art" != 1 ]] && use_art=0
        if [[ "$use_art" -eq 1 ]]; then
            options+=(2 "Turn off showing ES art during launch (currently on)")
        else
            options+=(2 "Turn on showing ES art during launch (currently off)")
        fi

        iniGet "disable_joystick"
        local disable_joystick="$ini_value"
        [[ "$disable_joystick" != 1 ]] && disable_joystick=0
        if [[ "$disable_joystick" -eq 0 ]]; then
            options+=(3 "Turn off joystick control in pre launch menu (currently on)")
        else
            options+=(3 "Turn on joystick control in pre launch menu (currently off)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    governor_runcommand
                    ;;
                2)
                    iniSet "use_art" "$((use_art ^ 1))"
                    ;;
                3)
                    iniSet "disable_joystick" "$((disable_joystick ^ 1))"
                    ;;
            esac
        else
            break
        fi
    done
}
