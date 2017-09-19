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
rp_module_flags="noinstclean"

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
function enable_at_start_snesdev() {
    local mode="$1"
    iniConfig "=" "" "/etc/snesdev.cfg"
    clear
    printHeading "Enabling SNESDev on boot."

    case "$mode" in
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
            echo "[enable_at_start_snesdev] I do not understand what is going on here."
            ;;
    esac

}

function set_adapter_version_snesdev() {
    local ver="$1"
    iniConfig "=" "" "/etc/snesdev.cfg"
    if [[ "$ver" -eq 1 ]]; then
        iniSet "adapter_version" "1x"
    else
        iniSet "adapter_version" "2x"
    fi
}

function remove_snesdev() {
    make -C "$md_inst" uninstallservice
    make -C "$md_inst" uninstall
}

function gui_snesdev() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)"
        2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)"
        3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button)"
        4 "Switch to adapter version 1.X"
        5 "Switch to adapter version 2.X"
        D "Disable SNESDev on boot and SNESDev keyboard mapping"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                enable_at_start_snesdev 3
                make -C "$md_inst" installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling pads and button)."
                ;;
            2)
                enable_at_start_snesdev 1
                make -C "$md_inst" installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling only pads)."
                ;;
            3)
                enable_at_start_snesdev 2
                make -C "$md_inst" installservice
                printMsgs "dialog" "Enabled SNESDev on boot (polling only button)."
                ;;
            4)
                set_adapter_version_snesdev 1
                printMsgs "dialog" "Switched to adapter version 1.X."
                ;;
            5)
                set_adapter_version_snesdev 2
                printMsgs "dialog" "Switched to adapter version 2.X."
                ;;
            D)
                make -C "$md_inst" uninstallservice
                printMsgs "dialog" "Disabled SNESDev on boot."
                ;;
        esac
    fi
}
