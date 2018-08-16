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
rp_module_desc="The 'runcommand' launch script - needed for launching the emulators from the frontend"
rp_module_section="core"

function _update_hook_runcommand() {
    # make sure runcommand is always updated when updating retropie-setup
    rp_isInstalled "$md_idx" && install_bin_runcommand
}

function depends_runcommand() {
    local depends=()
    isPlatform "rpi" && depends+=(fbi)
    isPlatform "x11" && depends+=(feh)
    getDepends "${depends[@]}"
}

function install_bin_runcommand() {
    cp "$md_data/runcommand.sh" "$md_inst/"
    cp "$md_data/joy2key.py" "$md_inst/"
    chmod a+x "$md_inst/runcommand.sh"
    chmod a+x "$md_inst/joy2key.py"
    python -m compileall "$md_inst/joy2key.py"
    if [[ ! -f "$configdir/all/runcommand.cfg" ]]; then
        mkUserDir "$configdir/all"
        iniConfig " = " '"' "$configdir/all/runcommand.cfg"
        iniSet "use_art" "0"
        iniSet "disable_joystick" "0"
        iniSet "governor" ""
        iniSet "disable_menu" "0"
        iniSet "image_delay" "2"
        chown $user:$user "$configdir/all/runcommand.cfg"
    fi
    if [[ ! -f "$configdir/all/runcommand-launch-dialog.cfg" ]]; then
        dialog --create-rc "$configdir/all/runcommand-launch-dialog.cfg"
        chown $user:$user "$configdir/all/runcommand-launch-dialog.cfg"
    fi
    md_ret_require="$md_inst/runcommand.sh"
}

function governor_runcommand() {
    cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Configure CPU Governor on command launch" 22 86 16)
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
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        governor="${governors[$choice]}"
        iniSet "governor" "$governor"
        chown $user:$user "$configdir/all/runcommand.cfg"
    fi
}

function gui_runcommand() {
    local config="$configdir/all/runcommand.cfg"
    iniConfig " = " '"' "$config"
    chown $user:$user "$config"

    local cmd
    local option
    local default
    while true; do

        eval "$(loadModuleConfig \
            'disable_menu=0' \
            'use_art=0' \
            'disable_joystick=0' \
            'image_delay=2' \
        )"

        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Exit" --default-item "$default" --menu "Choose an option." 22 86 16)
        options=()

        if [[ "$disable_menu" -eq 0 ]]; then
            options+=(1 "Launch menu (currently: Enabled)")
        else
            options+=(1 "Launch menu (currently: Disabled)")
        fi

        if [[ "$use_art" -eq 1 ]]; then
            options+=(2 "Launch menu art (currently: Enabled)")
        else
            options+=(2 "Launch menu art (currently: Disabled)")
        fi

        if [[ "$disable_joystick" -eq 0 ]]; then
            options+=(3 "Launch menu joystick control (currently: Enabled)")
        else
            options+=(3 "Launch menu joystick control (currently: Disabled)")
        fi

        options+=(4 "Launch image delay in seconds (currently $image_delay)")
        options+=(5 "CPU configuration")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        default="$choice"
        case "$choice" in
            1)
                iniSet "disable_menu" "$((disable_menu ^ 1))"
                ;;
            2)
                iniSet "use_art" "$((use_art ^ 1))"
                ;;
            3)
                iniSet "disable_joystick" "$((disable_joystick ^ 1))"
                ;;
            4)
                cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the delay in seconds" 10 60 "$image_delay")
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                iniSet "image_delay" "$choice"
                ;;
            5)
                governor_runcommand
                ;;
        esac
    done
}
