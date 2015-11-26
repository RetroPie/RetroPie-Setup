#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

###### input configuration interface functions for scripts in configscripts ######

#######################################
# Interface functions
# There are 3 main interface functions for each of the input types (joystick/keyboard)
#
# function onstart_<filename without extension>_<inputtype>()
# is run at the start of the input configuration
# 
# function onend_<filename without extension>_<inputtype>()
# is run at the end of the input configuration
# 
# Arguments for the above two functions are
#   $1 - device type
#   $2 - device name
#
# Returns:
#   None
#
# function map_<filename without extension>_<inputtype>()
# is run for each of the inputs - with the following arguments
#
# Arguments:
#   $1 - device type
#   $2 - device name
#   $3 - input name
#   $4 - input type
#   $5 - input ID
#   $6 - input value
#
# $1 - device type is currently either joystick or keyboard
# $2 - input name is one of the following
#   up, down, left, right
#   a, b, x, y
#   leftbottom, rightbottom, lefttop, righttop
#   leftthumb. rightthumb
#   start, select
#   leftanalogup, leftanalogdown, leftanalogleft, leftanalogright
#   rightanalogup, rightanalogdown, rightanalogleft, rightanalogright
# $3 - input type is button, axis, or hat
#
# Returns:
#   None
#
# Globals:
#   $home - the home directory of the user
#######################################

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
    done < <(xmlstarlet sel  -t -m "/inputList/inputConfig/input"  -v "concat(@name,' ',@type,' ',@id,' ',@value)" -n "$es_conf")

    local inputscriptdir=$(dirname "$0")
    local inputscriptdir=$(cd "$inputscriptdir" && pwd)

    local device_type=$(xmlstarlet sel -t -v "/inputList/inputConfig/@type" "$es_conf")
    local device_name=$(xmlstarlet sel -t -v "/inputList/inputConfig/@deviceName" "$es_conf")

    echo "Input type is '$device_type'."

    local module
    # call all configuration modules with the
    for module in $(find "$inputscriptdir/configscripts/" -maxdepth 1 -name "*.sh" | sort); do

        source "$module"  # register functions from emulatorconfigs folder
        local module_id=${module##*/}
        local module_id=${module_id%.sh}
        echo "Configuring '$module_id'"

        # at the start, the onstart_module function is called
        local funcname="onstart_${module_id}_${device_type}"
        fn_exists "$funcname" && "$funcname" "$device_type" "$device_name"

        local input_name
        # loop through all buttons and use corresponding config function if it exists
        for input_name in "${!mapping[@]}"; do
            funcname="map_${module_id}_${device_type}"

            if fn_exists "$funcname"; then
                local params=(${mapping[$input_name]})
                local input_type=${params[0]}
                local input_id=${params[1]}
                local input_value=${params[2]}

                "$funcname" "$device_type" "$device_name" "$input_name" "$input_type" "$input_id" "$input_value"
            fi
        done

        # at the end, the onend_module function is called
        funcname="onend_${module_id}_${device_type}"
        fn_exists "$funcname" && "$funcname" "$device_type" "$device_name"

    done

}

function fn_exists() {
    declare -f "$1" > /dev/null
    return $?
}

###### main ######

user=$(id -un)
home="$(eval echo ~$user)"

rootdir="/opt/retropie"
configdir="$rootdir/configs"

source "$rootdir/lib/inifuncs.sh"

inputconfiguration
