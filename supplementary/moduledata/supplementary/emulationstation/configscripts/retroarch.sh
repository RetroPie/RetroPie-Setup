#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

###### input configuration interface functions ######

#######################################
# Interface functions
# All interface functions get the same arguments. The naming scheme of the interface 
# functions is defined as following:
#
# function <button name>_inputconfig_<filename without extension>(),
#
# where <button name> is one of [ "up", 
#                                 "right", 
#                                 "down", 
#                                 "left", 
#                                 "a", 
#                                 "b", 
#                                 "x", 
#                                 "y", 
#                                 "leftbottom", 
#                                 "rightbottom", 
#                                 "lefttop", 
#                                 "righttop", 
#                                 "leftthumb", 
#                                 "rightthumb", 
#                                 "start", 
#                                 "select", 
#                                 "leftanalogright", 
#                                 "leftanalogleft", 
#                                 "leftanalogdown", 
#                                 "leftanalogup", 
#                                 "rightanalogright", 
#                                 "rightanalogleft", 
#                                 "rightanalogdown", 
#                                 "rightanalogup",
#                                 "onleave" ].
#
# Globals:
#   $home - the home directory of the user
#
# Arguments:
#   $1 - device type
#   $2 - device name
#   $3 - input name
#   $4 - input type
#   $5 - input ID
#   $6 - input value
#
# Returns:
#   None
#######################################

function up_inputconfig_retroarch() {
    local deviceName=$2
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"

    inputconfig_retroarch_iniSet "input_device" "$deviceName"
    inputconfig_retroarch_iniSet "input_driver" "udev"

    inputconfig_retroarch_iniSet "input_up_btn" "$(inputconfig_retroarch_getButtonString "up" "$inputType" "$inputID" "$inputValue")"
}

function right_inputconfig_retroarch() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"

    inputconfig_retroarch_iniSet "input_right_btn" "$(inputconfig_retroarch_getButtonString "right" "$inputType" "$inputID" "$inputValue")"
    inputconfig_retroarch_iniSet "input_state_slot_increase_btn" "$(inputconfig_retroarch_getButtonString "right" "$inputType" "$inputID" "$inputValue")"
}

function down_inputconfig_retroarch() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    configfile="tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"

    inputconfig_retroarch_iniSet "input_down_btn" "$(inputconfig_retroarch_getButtonString "down" "$inputType" "$inputID" "$inputValue")"
}

function left_inputconfig_retroarch() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"

    inputconfig_retroarch_iniSet "input_left_btn" "$(inputconfig_retroarch_getButtonString "left" "$inputType" "$inputID" "$inputValue")"
    inputconfig_retroarch_iniSet "input_state_slot_decrease_btn" "$(inputconfig_retroarch_getButtonString "left" "$inputType" "$inputID" "$inputValue")"
}

function a_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_a_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function b_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_b_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    inputconfig_retroarch_iniSet "input_reset_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function x_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_x_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    inputconfig_retroarch_iniSet "input_menu_toggle_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function y_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_y_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftbottom_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    inputconfig_retroarch_iniSet "input_load_state_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightbottom_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    inputconfig_retroarch_iniSet "input_save_state_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function lefttop_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l2_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function righttop_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r2_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftthumb_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l3_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightthumb_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r3_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function start_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_start_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    inputconfig_retroarch_iniSet "input_exit_emulator_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function select_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_select_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    inputconfig_retroarch_iniSet "input_enable_hotkey_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogright_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l_x_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogleft_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l_x_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogdown_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l_y_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogup_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_l_y_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogright_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r_x_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogleft_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r_x_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogdown_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r_y_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogup_inputconfig_retroarch() {
    configfile="./tempconfig.cfg"
    inputconfig_retroarch_iniConfig " = " "\"" "$configfile"
    inputconfig_retroarch_iniSet "input_r_y_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function onleave_inputconfig_retroarch() {
    local deviceType=$1
    local deviceName=$2
    newFilename=$(echo "$deviceName" | sed -e 's/ /_/g')".cfg"
    mv "./tempconfig.cfg" "$newFilename"
    if [[ -f "/opt/retropie/emulators/retroarch/configs/$newFilename" ]]; then
        mv "/opt/retropie/emulators/retroarch/configs/$newFilename" "/opt/retropie/emulators/retroarch/configs/$newFilename.bak"
    fi
    mv "$newFilename" "/opt/retropie/emulators/retroarch/configs/$newFilename"
    chown $user:$user "/opt/retropie/emulators/retroarch/configs/$newFilename"
}

###### helper functions ######
# to circumvent name collisions we use quite long function names in the following.
# all the following functions should have no dependencies to other shell scripts.

# arg 1: delimiter, arg 2: quote, arg 3: file
function inputconfig_retroarch_iniConfig() {
    __ini_cfg_delim="$1"
    __ini_cfg_quote="$2"
    __ini_cfg_file="$3"
}

# arg 1: command, arg 2: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function inputconfig_retroarch_iniProcess() {
    local cmd="$1"
    local key="$2"
    local value="$3"
    local file="$4"
    [[ -z "$file" ]] && file="$__ini_cfg_file"
    local delim="$__ini_cfg_delim"
    local quote="$__ini_cfg_quote"

    [[ -z "$file" ]] && fatalError "No file provided for ini/config change"
    [[ -z "$key" ]] && fatalError "No key provided for ini/config change on $file"

    # we strip the delimiter of spaces, so we can "fussy" match existing entries that have the wrong spacing
    local delim_strip=${delim// /}
    # if the stripped delimiter is empty - such as in the case of a space, just use the delimiter instead
    [[ -z "$delim_strip" ]] && delim_strip="$delim"
    local match_re="^[[:space:]#]*$key[[:space:]]*$delim_strip.*$"

    local match
    if [[ -f "$file" ]]; then
        match=$(egrep -i "$match_re" "$file" | tail -1)
    else
        touch "$file"
    fi

    if [[ "$cmd" == "del" ]]; then
        [[ -n "$match" ]] && sed -i -e "\|$match|d" "$file"
        return 0
    fi

    [[ "$cmd" == "unset" ]] && key="# $key"

    local replace="$key$delim$quote$value$quote"
    # echo "Setting $replace in $file"
    if [[ -z "$match" ]]; then
        # add key-value pair
        echo "$replace" >> "$file"
    else
        # replace existing key-value pair
        sed -i -e "s|$match|$replace|g" "$file"
    fi
}

# arg 1: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function inputconfig_retroarch_iniSet() {
    inputconfig_retroarch_iniProcess "set" "$1" "$2" "$3"
}

function inputconfig_retroarch_getButtonString() {
    local inputName=$1
    local inputType=$2
    local inputID=$3
    local inputValue=$4

    if [[ "$inputType" == "hat" ]]; then
        btnString="h"$inputID$inputName
    elif [[ "$inputType" == "axis" ]]; then
        if [[ "$inputValue" == "1" ]]; then
            btnString="+"$inputID
        else
            btnString="-"$inputID
        fi
    else
        btnString=$inputID
    fi
    echo "$btnString"
}
