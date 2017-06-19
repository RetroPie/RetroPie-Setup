#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function _get_config_pifba() {
    echo "$configdir/fba/fba2x.cfg"
}

function _split_config_pifba() {
    local cfg="$(_get_config_pifba)"
    sed -n '/\[Keyboard\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pifba-kb.cfg
    sed -n '/\[Joystick\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pifba-js.cfg
    sed -n '/\[Graphics\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pifba-gfx.cfg
}

function check_pifba() {
    [[ ! -f "$(_get_config_pifba)" ]] && return 1
    return 0
}

function onstart_pifba_joystick() {
    _split_config_pifba

    iniConfig "=" "" /tmp/pifba-js.cfg
}

function onstart_pifba_keyboard() {
    _split_config_pifba

    iniConfig "=" "" /tmp/pifba-kb.cfg

    sdl1_map
}

function map_pifba_keyboard() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local key
    case "$input_name" in
        up)
            key="UP_1"
            ;;
        down)
            key="DOWN_1"
            ;;
        left)
            key="LEFT_1"
            ;;
        right)
            key="RIGHT_1"
            ;;
        a)
            key="A_1"
            ;;
        b)
            key="B_1"
            ;;
        x)
            key="X_1"
            ;;
        y)
            key="Y_1"
            ;;
        leftbottom|leftshoulder)
            key="L_1"
            ;;
        rightbottom|rightshoulder)
            key="R_1"
            ;;
        start)
            key="START_1"
            ;;
        select)
            key="SELECT_1"
            ;;
        *)
            return
            ;;
    esac

    iniSet "$key" "${sdl1_map[$input_id]}"
}

function map_pifba_joystick() {
    local input_name="$3"
    local input_type="$4"
    local input_id="$5"
    local input_value="$6"

    local key
    case "$input_name" in
        up|down)
            key="JA_UD"
            ;;
        left|right)
            key="JA_LR"
            ;;
        a)
            key="A_1"
            ;;
        b)
            key="B_1"
            ;;
        x)
            key="X_1"
            ;;
        y)
            key="Y_1"
            ;;
        leftbottom|leftshoulder)
            key="L_1"
            ;;
        rightbottom|rightshoulder)
            key="R_1"
            ;;
        start)
            key="START_1"
            ;;
        select)
            key="SELECT_1"
            ;;
        leftthumb)
            key="QSAVE"
            ;;
        rightthumb)
            key="QLOAD"
            ;;
        *)
            return
            ;;
    esac

    iniSet "$key" "$input_id"
}

function onend_pifba_joystick() {
    local cfg="$configdir/fba/fba2x.cfg"
    cat "/tmp/pifba-kb.cfg" "/tmp/pifba-js.cfg" "/tmp/pifba-gfx.cfg" >"$cfg"
    rm /tmp/pifba-{kb,js,gfx}.cfg
}

function onend_pifba_keyboard() {
    onend_pifba_joystick
}
