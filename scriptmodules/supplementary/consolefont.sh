#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="consolefont"
rp_module_desc="Configure default console font size/type"
rp_module_section="config"
rp_module_flags="!x11"

function set_consolefont() {
    iniConfig "=" '"' "/etc/default/console-setup"
    iniSet "FONTFACE" "$1"
    iniSet "FONTSIZE" "$2"
    service console-setup restart
    # force font configuration update if running from a pseudo-terminal
    [[ "$(tty | egrep '/dev/tty[1-6]')" == "" ]] && setupcon -f --force
}

function check_consolefont() {
    local fontface
    local fontsize

    iniConfig "=" '"' "/etc/default/console-setup"
    iniGet "FONTFACE"
    fontface="$ini_value"
    iniGet "FONTSIZE"
    fontsize="$ini_value"
    echo "$fontface" "$fontsize"
}

function gui_consolefont() {
    local cmd
    local options
    local choices

    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired console font configuration: \n(Current configuration: $(check_consolefont))" 22 86 16)
    options=(
        1 "Large (VGA 16x32)"
        2 "Large (TerminusBold 16x32)"
        3 "Medium (VGA 16x28)"
        4 "Medium (TerminusBold 14x28)"
        5 "Small (Fixed 8x16)"
        6 "Smaller (VGA 8x8)"
        D "Default (Kernel font 8x16 - Restart needed)"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                set_consolefont "VGA" "16x32"
                ;;
            2)
                set_consolefont "TerminusBold" "16x32"
                ;;
            3)
                set_consolefont "VGA" "16x28"
                ;;
            4)
                set_consolefont "TerminusBold" "14x28"
                ;;
            5)
                set_consolefont "Fixed" "8x16"
                ;;
            6)
                set_consolefont "VGA" "8x8"
                ;;
            D)
                set_consolefont "" ""
                ;;
        esac
        if [[ "$choice" == "D" ]]; then
            printMsgs "dialog" "Default font will be used (provided by the Kernel).\n\nYou will need to reboot to see the change."
        else
            printMsgs "dialog" "New font configuration applied: $(check_consolefont)"
        fi
    fi
}
