#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="snesdev"
rp_module_desc="SNESDev (Driver for the RetroPie GPIO-Adapter)"
rp_module_section="driver"

function sources_snesdev() {
    gitPullOrClone "$md_inst" https://github.com/petrockblog/SNESDev-RPi.git
}

function build_snesdev() {
    cd "$md_inst"
    make -j1
    md_ret_require="$md_inst/src/SNESDev"
}

function install_snesdev() {
    cd "$md_inst"
    make install
}

# start SNESDev on boot and configure RetroArch input settings
function sup_enableSNESDevAtStart() {
    iniConfig "=" "" "/etc/snesdev.cfg"
    clear
    printHeading "Enabling SNESDev on boot."

    case $1 in
        1)
            iniSet "button_enabled" "0"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            ;;
        2)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "0"
            iniSet "gamepad2_enabled" "0"
            ;;
        3)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            ;;
        *)
            echo "[sup_enableSNESDevAtStart] I do not understand what is going on here."
            ;;
    esac

}

function sup_snesdevAdapterversion() {
    iniConfig "=" "" "/etc/snesdev.cfg"
    if [[ $1 -eq 1 ]]; then
        iniSet "adapter_version" "1x"
    elif [[ $1 -eq 2 ]]; then
        iniSet "adapter_version" "2x"
    else
        iniSet "adapter_version" "2x"
    fi
}

function gui_snesdev() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    options=(
        1 "Disable SNESDev on boot and SNESDev keyboard mapping."
        2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)."
        3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)."
        4 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button)."
        5 "Switch to adapter version 1.X."
        6 "Switch to adapter version 2.X."
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                make -C "$md_inst" uninstallservice
                printMsgs "dialog" "Disabled SNESDev on boot."
                ;;
            2)
                sup_enableSNESDevAtStart 3
                make -C "$md_inst" make installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling pads and button)."
                ;;
            3)
                sup_enableSNESDevAtStart 1
                make -C "$md_inst" make installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling only pads)."
                ;;
            4)
                sup_enableSNESDevAtStart 2
                make -C "$md_inst" make installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling only button)."
                ;;
            5)
                sup_snesdevAdapterversion 1
                printMsgs "dialog" "Switched to adapter version 1.X."
                ;;
            6)
                sup_snesdevAdapterversion 2
                printMsgs "dialog" "Switched to adapter version 2.X."
                ;;
        esac
    fi
}
