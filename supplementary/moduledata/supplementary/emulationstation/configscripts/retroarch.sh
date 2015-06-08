#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

function onstart_inputconfig_retroarch_joystick() {
    local deviceName=$2
    iniConfig " = " "\"" "./tempconfig.cfg"
    iniSet "input_device" "$deviceName"
    iniSet "input_driver" "udev"
}

function up_inputconfig_retroarch_joystick() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_up_btn" "$(inputconfig_retroarch_getButtonString "up" "$inputType" "$inputID" "$inputValue")"
}

function right_inputconfig_retroarch_joystick() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_right_btn" "$(inputconfig_retroarch_getButtonString "right" "$inputType" "$inputID" "$inputValue")"
    iniSet "input_state_slot_increase_btn" "$(inputconfig_retroarch_getButtonString "right" "$inputType" "$inputID" "$inputValue")"
}

function down_inputconfig_retroarch_joystick() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_down_btn" "$(inputconfig_retroarch_getButtonString "down" "$inputType" "$inputID" "$inputValue")"
}

function left_inputconfig_retroarch_joystick() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_left_btn" "$(inputconfig_retroarch_getButtonString "left" "$inputType" "$inputID" "$inputValue")"
    iniSet "input_state_slot_decrease_btn" "$(inputconfig_retroarch_getButtonString "left" "$inputType" "$inputID" "$inputValue")"
}

function a_inputconfig_retroarch_joystick() {
    iniSet "input_a_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function b_inputconfig_retroarch_joystick() {
    iniSet "input_b_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    iniSet "input_reset_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function x_inputconfig_retroarch_joystick() {
    iniSet "input_x_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    iniSet "input_menu_toggle_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function y_inputconfig_retroarch_joystick() {
    iniSet "input_y_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftbottom_inputconfig_retroarch_joystick() {
    iniSet "input_l_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    iniSet "input_load_state_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightbottom_inputconfig_retroarch_joystick() {
    iniSet "input_r_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    iniSet "input_save_state_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function lefttop_inputconfig_retroarch_joystick() {
    iniSet "input_l2_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function righttop_inputconfig_retroarch_joystick() {
    iniSet "input_r2_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftthumb_inputconfig_retroarch_joystick() {
    iniSet "input_l3_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightthumb_inputconfig_retroarch_joystick() {
    iniSet "input_r3_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function start_inputconfig_retroarch_joystick() {
    iniSet "input_start_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    iniSet "input_exit_emulator_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function select_inputconfig_retroarch_joystick() {
    iniSet "input_select_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
    iniSet "input_enable_hotkey_btn" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogright_inputconfig_retroarch_joystick() {
    iniSet "input_l_x_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogleft_inputconfig_retroarch_joystick() {
    iniSet "input_l_x_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogdown_inputconfig_retroarch_joystick() {
    iniSet "input_l_y_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function leftanalogup_inputconfig_retroarch_joystick() {
    iniSet "input_l_y_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogright_inputconfig_retroarch_joystick() {
    iniSet "input_r_x_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogleft_inputconfig_retroarch_joystick() {
    iniSet "input_r_x_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogdown_inputconfig_retroarch_joystick() {
    iniSet "input_r_y_plus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function rightanalogup_inputconfig_retroarch_joystick() {
    iniSet "input_r_y_minus_axis" "$(inputconfig_retroarch_getButtonString "$3" "$4" "$5" "$6")"
}

function onend_inputconfig_retroarch_joystick() {
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


### input type: Keyboard ###

function onstart_inputconfig_retroarch_keyboard() {
    iniConfig " = " "" "/opt/retropie/configs/all/retroarch.cfg"

    declare -Ag retroarchkeymap
    # SDL codes from https://wiki.libsdl.org/SDLKeycodeLookup
    retroarchkeymap["1073741904"]="left"
    retroarchkeymap["1073741903"]="right"
    retroarchkeymap["1073741906"]="up"
    retroarchkeymap["1073741905"]="down"
    retroarchkeymap["13"]="enter"
    retroarchkeymap["1073741912"]="kp_enter"
    retroarchkeymap["9"]="tab"
    retroarchkeymap["1073741897"]="insert"
    retroarchkeymap["127"]="del"
    retroarchkeymap["1073741901"]="end"
    retroarchkeymap["1073741898"]="home"
    retroarchkeymap["1073742053"]="rshift"
    retroarchkeymap["1073742049"]="shift"
    retroarchkeymap["1073742048"]="ctrl"
    retroarchkeymap["1073742050"]="alt"
    retroarchkeymap["32"]="space"
    retroarchkeymap["27"]="escape"
    retroarchkeymap["43"]="add"
    retroarchkeymap["45"]="subtract"
    retroarchkeymap["1073741911"]="kp_plus"
    retroarchkeymap["1073741910"]="kp_minus"
    retroarchkeymap["1073741882"]="f1"
    retroarchkeymap["1073741883"]="f2"
    retroarchkeymap["1073741884"]="f3"
    retroarchkeymap["1073741885"]="f4"
    retroarchkeymap["1073741886"]="f5"
    retroarchkeymap["1073741887"]="f6"
    retroarchkeymap["1073741888"]="f7"
    retroarchkeymap["1073741889"]="f8"
    retroarchkeymap["1073741890"]="f9"
    retroarchkeymap["1073741891"]="f10"
    retroarchkeymap["1073741892"]="f11"
    retroarchkeymap["1073741893"]="f12"
    retroarchkeymap["48"]="num0"
    retroarchkeymap["49"]="num1"
    retroarchkeymap["50"]="num2"
    retroarchkeymap["51"]="num3"
    retroarchkeymap["52"]="num4"
    retroarchkeymap["53"]="num5"
    retroarchkeymap["54"]="num6"
    retroarchkeymap["55"]="num7"
    retroarchkeymap["56"]="num8"
    retroarchkeymap["57"]="num9"
    retroarchkeymap["1073741899"]="pageup"
    retroarchkeymap["1073741902"]="pagedown"
    retroarchkeymap["1073741922"]="keypad0"
    retroarchkeymap["1073741913"]="keypad1"
    retroarchkeymap["1073741914"]="keypad2"
    retroarchkeymap["1073741915"]="keypad3"
    retroarchkeymap["1073741916"]="keypad4"
    retroarchkeymap["1073741917"]="keypad5"
    retroarchkeymap["1073741918"]="keypad6"
    retroarchkeymap["1073741919"]="keypad7"
    retroarchkeymap["1073741920"]="keypad8"
    retroarchkeymap["1073741921"]="keypad9"
    retroarchkeymap["46"]="period"
    retroarchkeymap["1073741881"]="capslock"
    retroarchkeymap["1073741907"]="numlock"
    retroarchkeymap["8"]="backspace"
    retroarchkeymap["42"]="multiply"
    retroarchkeymap["47"]="divide"
    retroarchkeymap["1073741894"]="print_screen"
    retroarchkeymap["1073741895"]="scroll_lock"
    retroarchkeymap["96"]="backquote"
    retroarchkeymap["1073741896"]="pause"
    retroarchkeymap["39"]="quote"
    retroarchkeymap["44"]="comma"
    retroarchkeymap["45"]="minus"
    retroarchkeymap["47"]="slash"
    retroarchkeymap["59"]="semicolon"
    retroarchkeymap["61"]="equals"
    retroarchkeymap["91"]="leftbracket"
    retroarchkeymap["92"]="backslash"
    retroarchkeymap["93"]="rightbracket"
    retroarchkeymap["1073741923"]="kp_period"
    retroarchkeymap["1073741927"]="kp_equals"
    retroarchkeymap["1073742052"]="rctrl"
    retroarchkeymap["1073742054"]="ralt"
    retroarchkeymap["97"]="a"
    retroarchkeymap["98"]="b"
    retroarchkeymap["99"]="c"
    retroarchkeymap["100"]="d"
    retroarchkeymap["101"]="e"
    retroarchkeymap["102"]="f"
    retroarchkeymap["103"]="g"
    retroarchkeymap["104"]="h"
    retroarchkeymap["105"]="i"
    retroarchkeymap["106"]="j"
    retroarchkeymap["107"]="k"
    retroarchkeymap["108"]="l"
    retroarchkeymap["109"]="m"
    retroarchkeymap["110"]="n"
    retroarchkeymap["111"]="o"
    retroarchkeymap["112"]="p"
    retroarchkeymap["113"]="q"
    retroarchkeymap["114"]="r"
    retroarchkeymap["115"]="s"
    retroarchkeymap["116"]="t"
    retroarchkeymap["117"]="u"
    retroarchkeymap["118"]="v"
    retroarchkeymap["119"]="w"
    retroarchkeymap["120"]="x"
    retroarchkeymap["121"]="y"
    retroarchkeymap["122"]="z"
}

function up_inputconfig_retroarch_keyboard() {
    local deviceName=$2
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_player1_up" "${retroarchkeymap[$inputID]}"
}

function right_inputconfig_retroarch_keyboard() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_player1_right" "${retroarchkeymap[$inputID]}"
}

function down_inputconfig_retroarch_keyboard() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_player1_down" "${retroarchkeymap[$inputID]}"
}

function left_inputconfig_retroarch_keyboard() {
    local inputName=$3
    local inputType=$4
    local inputID=$5
    local inputValue=$6

    iniSet "input_player1_left" "${retroarchkeymap[$inputID]}"
}

# the following functions are kept a bit shorter than above, but they still follow the the mechanism

function a_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_a" "${retroarchkeymap[$5]}"
}

function b_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_b" "${retroarchkeymap[$5]}"
}

function x_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_x" "${retroarchkeymap[$5]}"
}

function y_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_y" "${retroarchkeymap[$5]}"
}

function leftbottom_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_l" "${retroarchkeymap[$5]}"
}

function rightbottom_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_r" "${retroarchkeymap[$5]}"
}

function lefttop_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_l2" "${retroarchkeymap[$5]}"
}

function righttop_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_r2" "${retroarchkeymap[$5]}"
}

function leftthumb_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_l3" "${retroarchkeymap[$5]}"
}

function rightthumb_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_r3" "${retroarchkeymap[$5]}"
}

function start_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_start" "${retroarchkeymap[$5]}"
}

function select_inputconfig_retroarch_keyboard() {
    iniSet "input_player1_select" "${retroarchkeymap[$5]}"
}


###### helper functions ######
# to circumvent name collisions we use quite long function names in the following.
# all the following functions should have no dependencies to other shell scripts.

function inputconfig_retroarch_getButtonString() {
    local inputName=$1
    local inputType=$2
    local inputID=$3
    local inputValue=$4

    if [[ "$inputType" == "hat" ]]; then
        btnString="h$inputID$inputName"
    elif [[ "$inputType" == "axis" ]]; then
        if [[ "$inputValue" == "1" ]]; then
            btnString="+$inputID"
        else
            btnString="-$inputID"
        fi
    else
        btnString=$inputID
    fi
    echo "$btnString"
}
