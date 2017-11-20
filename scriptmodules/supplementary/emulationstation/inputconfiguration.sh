#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

## @file scriptmodules/supplementary/emulationstation/inputconfiguration.sh
## @brief input configuration script
## @copyright GPLv3
## @details
## @par global variables
##
## There are 3 global variables which are set to the current device being processed
##
## `DEVICE_TYPE` = device type is currently either joystick, keyboard or cec
## `DEVICE_NAME` = name of the device
## `DEVICE_GUID` = SDL2 joystick GUID of the device (-1 for keyboard, -2 for cec)
##
## @par Interface functions
##
## each input configuration module can have an optional function
## `check_<filename without extension>`. If this function returns 1, the module is
## skipped. This can be used to skip input configurations in some cases - eg
## to skip configuration when an existing config file is not installed.
##
## There are 3 main interface functions for each of the input types (joystick/keyboard)
##
## function `onstart_<filename without extension>_<inputtype>()`
## is run at the start of the input configuration
##
## function `onend_<filename without extension>_<inputtype>()`
## is run at the end of the input configuration
##
## Returns:
##   None
##
## function map_<filename without extension>_<inputtype>()
## is run for each of the inputs - with the following arguments
##
## Arguments:
## * $1 - input name is one of the following
##  * up, down, left, right
##  * a, b, x, y
##  * leftshoulder, rightshoulder, lefttrigger, righttrigger
##  * leftthumb. rightthumb
##  * start, select
##  * leftanalogup, leftanalogdown, leftanalogleft, leftanalogright
##  * rightanalogup, rightanalogdown, rightanalogleft, rightanalogright
## * $2 - input type is button, axis or hat for joysticks, key for keyboard and button for cec.
## * $3 - button id of the input for a joystick, SDL2 keycode for a keyboard, or button id for cec.
## * $4 - value of the joystick input or 1 for keyboard and cec.
##
## Returns:
##   None

function inputconfiguration() {

    local es_conf="$home/.emulationstation/es_temporaryinput.cfg"
    declare -A mapping

    # check if we have the temporary input file
    [[ ! -f "$es_conf" ]] && return

    local line
    while read line; do
        if [[ -n "$line" ]]; then
            local input=($line)
            mapping["${input[0]}"]=${input[@]:1}
        fi
    done < <(xmlstarlet sel --text -t -m "/inputList/inputConfig/input"  -v "concat(@name,' ',@type,' ',@id,' ',@value)" -n "$es_conf")

    local inputscriptdir=$(dirname "$0")
    local inputscriptdir=$(cd "$inputscriptdir" && pwd)

    DEVICE_TYPE=$(xmlstarlet sel --text -t -v "/inputList/inputConfig/@type" "$es_conf")
    DEVICE_NAME=$(xmlstarlet sel --text -t -v "/inputList/inputConfig/@deviceName" "$es_conf")
    DEVICE_GUID=$(xmlstarlet sel --text -t -v "/inputList/inputConfig/@deviceGUID" "$es_conf")

    echo "Input type is '$DEVICE_TYPE'."

    local module
    # call all configuration modules with the
    for module in $(find "$inputscriptdir/configscripts/" -maxdepth 1 -name "*.sh" | sort); do

        source "$module"  # register functions from emulatorconfigs folder
        local module_id=${module##*/}
        local module_id=${module_id%.sh}

        local funcname="check_${module_id}"
        # call check_module to check if we should run it
        if fn_exists "$funcname"; then
            "$funcname" || continue
        fi

        echo "Configuring '$module_id'"

        # at the start, the onstart_module function is called.
        funcname="onstart_${module_id}_${DEVICE_TYPE}"
        fn_exists "$funcname" && "$funcname"

        local input_name
        # loop through all buttons and use corresponding config function if it exists
        for input_name in "${!mapping[@]}"; do
            funcname="map_${module_id}_${DEVICE_TYPE}"

            if fn_exists "$funcname"; then
                local params=(${mapping[$input_name]})
                local input_type=${params[0]}
                local input_id=${params[1]}
                local input_value=${params[2]}

                "$funcname" "$input_name" "$input_type" "$input_id" "$input_value"
            fi
        done

        # at the end, the onend_module function is called
        funcname="onend_${module_id}_${DEVICE_TYPE}"
        fn_exists "$funcname" && "$funcname"

    done

}

function fn_exists() {
    declare -f "$1" > /dev/null
    return $?
}

function sdl1_map() {
    # check if sdl1_map already exists
    [[ -v sdl1_map[@] ]] && return

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

###### main ######

user=$(id -un)
home="$(eval echo ~$user)"

rootdir="/opt/retropie"
configdir="$rootdir/configs"

source "$rootdir/lib/inifuncs.sh"

getAutoConf "disable" || inputconfiguration
