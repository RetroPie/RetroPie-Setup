#!/usr/bin/env bash

# This file is part of RetroPie.
#
# See the LICENSE.md file at the top-level directory of this distribution
#

###### input configuration interface functions for scripts in configscripts ######

#######################################
# Interface functions
# All interface functions get the same arguments. The naming scheme of the interface
# functions is defined as following:
#
# function <button name>_inputconfig_<filename without extension>(),
#
# where <button name> is one of [
#       "onstart"
#       "up",
#       "right",
#       "down",
#       "left",
#       "a",
#       "b",
#       "x",
#       "y",
#       "leftbottom",
#       "rightbottom",
#       "lefttop",
#       "righttop",
#       "leftthumb",
#       "rightthumb",
#       "start",
#       "select",
#       "leftanalogright",
#       "leftanalogleft",
#       "leftanalogdown",
#       "leftanalogup",
#       "rightanalogright",
#       "rightanalogleft",
#       "rightanalogdown",
#       "rightanalogup",
#       "onend"
#       ]
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

function inputconfiguration() {

    declare -a inputConfigButtonList=("up" "right" "down" "left" "a" "b" "x" "y" "leftbottom" "rightbottom" "lefttop" "righttop" "leftthumb" "rightthumb" "start" "select" "leftanalogright" "leftanalogleft" "leftanalogdown" "leftanalogup" "rightanalogright" "rightanalogleft" "rightanalogdown" "rightanalogup")

    local inputscriptdir=$(dirname "$0")
    local inputscriptdir=$(cd "$inputscriptdir" && pwd)

    # get input configuration from
    pushd "$inputscriptdir"

    # now should have the file "$home/.emulationstation/es_temporaryinput.cfg"
    if [[ -f "$home/.emulationstation/es_temporaryinput.cfg" ]]; then

        deviceType=$(getDeviceType)
        deviceName=$(getDeviceName)

        local userInputType=$(grep -o -e "inputConfig type=\"[a-z]*\"" "$home/.emulationstation/es_temporaryinput.cfg")
        local userInputType=${userInputType:18:-1}
        echo -e "Input type is '$userInputType'."

        # now we have the file ./userinput/inputconfig.xml and we use this information to configure all registered emulators
        # therefore the input type specific modules are called (if they exist)
        for module in $(find "$inputscriptdir/configscripts/" -maxdepth 1 -name "*.sh" | sort); do

            source "$module"  # register functions from emulatorconfigs folder
            local onlyFilename=$(basename "$module")
            echo "Configuring '$onlyFilename'"

            # at the start, the onstart_inputconfig_X function is called
            funcname="onstart_inputconfig_${onlyFilename::-3}_$userInputType"

            # if interface function is implemented
            fn_exists "$funcname" && "$funcname" "$deviceType" "$deviceName"

            # loop through all buttons and use corresponding config function if it exists
            for button in "${inputConfigButtonList[@]}"; do
                funcname="${button}_inputconfig_${onlyFilename::-3}_$userInputType"

                # if interface function is implemented
                if fn_exists "$funcname"; then
                    inputName=$(getInputAttribute "$button" "name")
                    inputType=$(getInputAttribute "$button" "type")
                    inputID=$(getInputAttribute "$button" "id")
                    inputValue=$(getInputAttribute "$button" "value")

                    # if input was defined
                    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName='$deviceName']/input[@name='$inputName'])" "$home/.emulationstation/es_temporaryinput.cfg") -ne 0 ]]; then
                        "$funcname" "$deviceType" "$deviceName" "$inputName" "$inputType" "$inputID" "$inputValue"
                    fi
                fi
            done

            # at the end, the onend_inputconfig_X function is called
            funcname="onend_inputconfig_${onlyFilename::-3}_$userInputType"

            # if interface function is implemented
            fn_exists "$funcname" && "$funcname" "$deviceType" "$deviceName"

        done

    fi
    popd

}

function fn_exists() {
    declare -f "$1" > /dev/null
    return $?
}

function getDeviceType() {
    xmlstarlet sel -t -v /inputList/inputConfig/@type "$home"/.emulationstation/es_temporaryinput.cfg
}

function getDeviceName() {
    xmlstarlet sel -t -v /inputList/inputConfig/@deviceName "$home"/.emulationstation/es_temporaryinput.cfg
}

function getInputAttribute() {
    inputName=\'$1\'
    attribute=$2
    deviceName=\'$(getDeviceName)\'
    xmlstarlet sel -t -v "/inputList/inputConfig[@deviceName=$deviceName]/input[@name=$inputName]/@$attribute" "$home"/.emulationstation/es_temporaryinput.cfg
}

# arg 1: delimiter, arg 2: quote, arg 3: file
function iniConfig() {
    __ini_cfg_delim="$1"
    __ini_cfg_quote="$2"
    __ini_cfg_file="$3"
}

# arg 1: command, arg 2: key, arg 2: value, arg 3: file (optional - uses file from iniConfig if not used)
function iniProcess() {
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
function iniSet() {
    iniProcess "set" "$1" "$2" "$3"
}

###### main ######

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)
home="$(eval echo ~$user)"

inputconfiguration
