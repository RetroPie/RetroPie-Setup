#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_retroarch_joystick() {
    iniConfig " = " '"' "$configdir/all/retroarch.cfg"
    iniGet "input_joypad_driver"
    local input_joypad_driver="$ini_value"
    if [[ -z "$input_joypad_driver" ]]; then
        input_joypad_driver="udev"
    fi

    _retroarch_select_hotkey=1

    _atebitdo_hack=0
    getAutoConf "8bitdo_hack" && _atebitdo_hack=1

    iniConfig " = " "\"" "/tmp/tempconfig.cfg"
    iniSet "input_device" "$DEVICE_NAME"
    iniSet "input_driver" "$input_joypad_driver"
}

function onstart_retroarch_keyboard() {
    iniConfig " = " '"' "$configdir/all/retroarch.cfg"

    _retroarch_select_hotkey=1

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

    # special case for disabled hotkey
    retroarchkeymap["0"]="nul"
}

function map_retroarch_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local keys
    case "$input_name" in
        up)
            keys=("input_up")
            ;;
        down)
            keys=("input_down")
            ;;
        left)
            keys=("input_left" "input_state_slot_decrease")
            ;;
        right)
            keys=("input_right" "input_state_slot_increase")
            ;;
        a)
            keys=("input_a")
            ;;
        b)
            keys=("input_b" "input_reset")
            ;;
        x)
            keys=("input_x" "input_menu_toggle")
            ;;
        y)
            keys=("input_y")
            ;;
        leftbottom|leftshoulder)
            keys=("input_l" "input_load_state")
            ;;
        rightbottom|rightshoulder)
            keys=("input_r" "input_save_state")
            ;;
        lefttop|lefttrigger)
            keys=("input_l2")
            ;;
        righttop|righttrigger)
            keys=("input_r2")
            ;;
        leftthumb)
            keys=("input_l3")
            ;;
        rightthumb)
            keys=("input_r3")
            ;;
        start)
            keys=("input_start" "input_exit_emulator")
            ;;
        select)
            keys=("input_select")
            ;;
        leftanalogleft)
            keys=("input_l_x_minus")
            ;;
        leftanalogright)
            keys=("input_l_x_plus")
            ;;
        leftanalogup)
            keys=("input_l_y_minus")
            ;;
        leftanalogdown)
            keys=("input_l_y_plus")
            ;;
        rightanalogleft)
            keys=("input_r_x_minus")
            ;;
        rightanalogright)
            keys=("input_r_x_plus")
            ;;
        rightanalogup)
            keys=("input_r_y_minus")
            ;;
        rightanalogdown)
            keys=("input_r_y_plus")
            ;;
        hotkeyenable)
            keys=("input_enable_hotkey")
            _retroarch_select_hotkey=0
            if [[ "$input_type" == "key" && "$input_id" == "0" ]]; then
                return
            fi
            ;;
        *)
            return
            ;;
    esac

    local key
    local value
    local type
    for key in "${keys[@]}"; do
        case "$input_type" in
            hat)
                type="btn"
                value="h$input_id$input_name"
                ;;
            axis)
                type="axis"
                if [[ "$input_value" == "1" ]]; then
                    value="+$input_id"
                else
                    value="-$input_id"
                fi
                ;;
            *)
                type="btn"
                value="$input_id"

                # workaround for mismatched controller mappings
                iniGet "input_driver"
                if [[ "$ini_value" == "udev" ]]; then
                    case "$DEVICE_NAME" in
                        "8Bitdo FC30"*|"8Bitdo NES30"*|"8Bitdo SFC30"*|"8Bitdo SNES30"*|"8Bitdo Zero"*)
                            if [[ "$_atebitdo_hack" -eq 1 ]]; then
                                value="$((input_id+11))"
                            fi
                            ;;
                    esac
                fi
                ;;
        esac
        if [[ "$input_name" == "select" && "$_retroarch_select_hotkey" -eq 1 ]]; then
            _retroarch_select_type="$type"
        fi
        key+="_$type"
        iniSet "$key" "$value"
    done
}

function map_retroarch_keyboard() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local key
    case "$input_name" in
        up)
            keys=("input_player1_up")
            ;;
        down)
            keys=("input_player1_down")
            ;;
        left)
            keys=("input_player1_left" "input_state_slot_decrease")
            ;;
        right)
            keys=("input_player1_right" "input_state_slot_increase")
            ;;
        a)
            keys=("input_player1_a")
            ;;
        b)
            keys=("input_player1_b" "input_reset")
            ;;
        x)
            keys=("input_player1_x" "input_menu_toggle")
            ;;
        y)
            keys=("input_player1_y")
            ;;
        leftbottom|leftshoulder)
            keys=("input_player1_l")
            ;;
        rightbottom|rightshoulder)
            keys=("input_player1_r")
            ;;
        lefttop|lefttrigger)
            keys=("input_player1_l2")
            ;;
        righttop|righttrigger)
            keys=("input_player1_r2")
            ;;
        leftthumb)
            keys=("input_player1_l3")
            ;;
        rightthumb)
            keys=("input_player1_r3")
            ;;
        start)
            keys=("input_player1_start" "input_exit_emulator")
            ;;
        select)
            keys=("input_player1_select")
            ;;
        hotkeyenable)
            keys=("input_enable_hotkey")
            _retroarch_select_hotkey=0
            ;;
        *)
            return
            ;;
    esac

    for key in "${keys[@]}"; do
        iniSet "$key" "${retroarchkeymap[$input_id]}"
    done
}

function onend_retroarch_joystick() {
    # if $_retroarch_select_hotkey is set here, then there was no hotkeyenable button
    # in the configuration, so we should use the select button as hotkey enable if set
    if [[ "$_retroarch_select_hotkey" -eq 1 ]]; then
        iniGet "input_select_${_retroarch_select_type}"
        [[ -n "$ini_value" ]] && iniSet "input_enable_hotkey_${_retroarch_select_type}" "$ini_value"
    fi

    # hotkey sanity check
    # remove hotkeys if there is no hotkey enable button
    if ! grep -q "input_enable_hotkey" /tmp/tempconfig.cfg; then
        local key
        for key in input_state_slot_decrease input_state_slot_increase input_reset input_menu_toggle input_load_state input_save_state input_exit_emulator; do
            sed -i "/$key/d" /tmp/tempconfig.cfg
        done
    fi

    # disable any auto configs for the same device to avoid duplicates
    local file
    local dir="$configdir/all/retroarch-joypads"
    while read -r file; do
        mv "$file" "$file.bak"
    done < <(grep -Fl "\"$DEVICE_NAME\"" "$dir/"*.cfg 2>/dev/null)

    # sanitise filename
    file="${DEVICE_NAME//[\?\<\>\\\/:\*\|]/}.cfg"

    if [[ -f "$dir/$file" ]]; then
        mv "$dir/$file" "$dir/$file.bak"
    fi
    mv "/tmp/tempconfig.cfg" "$dir/$file"
}

function onend_retroarch_keyboard() {
    if [[ "$_retroarch_select_hotkey" -eq 1 ]]; then
        iniGet "input_player1_select"
        iniSet "input_enable_hotkey" "$ini_value"
    fi

    # hotkey sanity check
    # remove hotkeys if there is no hotkey enable button
    iniGet "input_enable_hotkey"
    if [[ -z "$ini_value" || "$ini_value" == "nul" ]]; then
        iniSet "input_state_slot_decrease" ""
        iniSet "input_state_slot_increase" ""
        iniSet "input_reset" ""
        iniSet "input_menu_toggle" "f1"
        iniSet "input_load_state" ""
        iniSet "input_save_state" ""
        iniSet "input_exit_emulator" "escape"
        iniSet "input_shader_next" ""
        iniSet "input_shader_prev" ""
        iniSet "input_rewind" ""
    fi
}
