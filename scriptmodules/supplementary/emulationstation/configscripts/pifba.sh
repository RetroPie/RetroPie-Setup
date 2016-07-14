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
    [[ ! -f "$cfg" ]]
    sed -n -e '/\[Keyboard\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pifba-kb.cfg
    sed -n -e '/\[Joystick\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pifba-js.cfg
    sed -n -e '/\[Graphics\]/,/\[/p' "$cfg" | head -n -1 >/tmp/pifba-gfx.cfg
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

    # SDL codes from https://wiki.libsdl.org/SDLKeycodeLookup mapped to /usr/include/SDL/SDL_keysym.h
    declare -Ag sdl1_map
    local i
    for i in {0..127}; do
        sdl1_map["$i"]="$i"
    done

    sdl1_map["1073741881"]="301" # SDLK SDLK_CAPSLOCK
    sdl1_map["1073741882"]="282" # SDLK SDLK_F1
    sdl1_map["1073741883"]="283" # SDLK SDLK_F2
    sdl1_map["1073741884"]="284" # SDLK SDLK_F3
    sdl1_map["1073741885"]="285" # SDLK SDLK_F4
    sdl1_map["1073741886"]="286" # SDLK SDLK_F5
    sdl1_map["1073741887"]="287" # SDLK SDLK_F6
    sdl1_map["1073741888"]="288" # SDLK SDLK_F7
    sdl1_map["1073741889"]="289" # SDLK SDLK_F8
    sdl1_map["1073741890"]="290" # SDLK SDLK_F9
    sdl1_map["1073741891"]="291" # SDLK SDLK_F10
    sdl1_map["1073741892"]="292" # SDLK SDLK_F11
    sdl1_map["1073741893"]="293" # SDLK SDLK_F12
    sdl1_map["1073741894"]="316" # SDLK SDLK_PRINTSCREEN
    sdl1_map["1073741895"]="302" # SDLK SDLK_SCROLLLOCK
    sdl1_map["1073741896"]="19"  # SDLK SDLK_PAUSE
    sdl1_map["1073741897"]="277" # SDLK SDLK_INSERT
    sdl1_map["1073741898"]="278" # SDLK SDLK_HOME
    sdl1_map["1073741899"]="280" # SDLK SDLK_PAGEUP
    sdl1_map["1073741901"]="279" # SDLK SDLK_END
    sdl1_map["1073741902"]="281" # SDLK SDLK_PAGEDOWN
    sdl1_map["1073741903"]="275" # SDLK SDLK_RIGHT
    sdl1_map["1073741904"]="276" # SDLK SDLK_LEFT
    sdl1_map["1073741905"]="274" # SDLK SDLK_DOWN
    sdl1_map["1073741906"]="273" # SDLK SDLK_UP
    sdl1_map["1073741908"]="267" # SDLK SDLK_KP_DIVIDE
    sdl1_map["1073741909"]="268" # SDLK SDLK_KP_MULTIPLY
    sdl1_map["1073741910"]="269" # SDLK SDLK_KP_MINUS
    sdl1_map["1073741911"]="270" # SDLK SDLK_KP_PLUS
    sdl1_map["1073741912"]="271" # SDLK SDLK_KP_ENTER
    sdl1_map["1073741913"]="257" # SDLK SDLK_KP_1
    sdl1_map["1073741914"]="258" # SDLK SDLK_KP_2
    sdl1_map["1073741915"]="259" # SDLK SDLK_KP_3
    sdl1_map["1073741916"]="260" # SDLK SDLK_KP_4
    sdl1_map["1073741917"]="261" # SDLK SDLK_KP_5
    sdl1_map["1073741918"]="262" # SDLK SDLK_KP_6
    sdl1_map["1073741919"]="263" # SDLK SDLK_KP_7
    sdl1_map["1073741920"]="264" # SDLK SDLK_KP_8
    sdl1_map["1073741921"]="265" # SDLK SDLK_KP_9
    sdl1_map["1073741922"]="256" # SDLK SDLK_KP_0
    sdl1_map["1073741923"]="266" # SDLK SDLK_KP_PERIOD
    sdl1_map["1073741926"]="320" # SDLK SDLK_POWER
    sdl1_map["1073741927"]="272" # SDLK SDLK_KP_EQUALS
    sdl1_map["1073741928"]="294" # SDLK SDLK_F13
    sdl1_map["1073741929"]="295" # SDLK SDLK_F14
    sdl1_map["1073741930"]="296" # SDLK SDLK_F15
    sdl1_map["1073741941"]="315" # SDLK SDLK_HELP
    sdl1_map["1073741942"]="319" # SDLK SDLK_MENU
    sdl1_map["1073741946"]="322" # SDLK SDLK_UNDO
    sdl1_map["1073741978"]="317" # SDLK SDLK_SYSREQ
    sdl1_map["1073742048"]="306" # SDLK SDLK_LCTRL
    sdl1_map["1073742049"]="304" # SDLK SDLK_LSHIFT
    sdl1_map["1073742050"]="308" # SDLK SDLK_LALT
    sdl1_map["1073742051"]="311" # SDLK SDLK_LGUI
    sdl1_map["1073742052"]="305" # SDLK SDLK_RCTRL
    sdl1_map["1073742053"]="303" # SDLK SDLK_RSHIFT
    sdl1_map["1073742054"]="307" # SDLK SDLK_RALT
    sdl1_map["1073742055"]="312" # SDLK SDLK_RGUI
    sdl1_map["1073742081"]="313" # SDLK SDLK_MODE
}

function map_pifba_keyboard() {
    local device_type="$1"
    local device_name="$2"
    local input_name="$3"
    local input_type="$4"
    local input_id="$5"
    local input_value="$6"

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
    local device_type="$1"
    local device_name="$2"
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
