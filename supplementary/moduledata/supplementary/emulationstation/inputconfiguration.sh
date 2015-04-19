#!/usr/bin/env bash

# This file is part of RetroPie.
#
# See the LICENSE.md file at the top-level directory of this distribution
#

function inputconfiguration() {

    declare -a inputConfigButtonList=("up" "right" "down" "left" "a" "b" "x" "y" "leftbottom" "rightbottom" "lefttop" "righttop" "leftthumb" "rightthumb" "start" "select" "leftanalogright" "leftanalogleft" "leftanalogdown" "leftanalogup" "rightanalogright" "rightanalogleft" "rightanalogdown" "rightanalogup")

    local inputscriptdir=$(dirname "$0")
    local inputscriptdir=$(cd "$inputscriptdir" && pwd)

    # get input configuration from 
    pushd $inputscriptdir

    # now should have the file "$home"/.emulationstation/es_temporaryinput.cfg"
    if [[ -f "$home"/.emulationstation/es_temporaryinput.cfg ]]; then

        deviceType=$(getDeviceType)
        deviceName=$(getDeviceName)

        # now we have the file ./userinput/inputconfig.xml and we use this information to configure all registered emulators
        for module in $(find "$inputscriptdir/configscripts/" -maxdepth 1 -name "*.sh" | sort); do

            source "$module"  # register functions from emulatorconfigs folder
            local onlyFilename=$(basename "$module")
            echo "Configuring '$onlyFilename'"

            # loop through all buttons and use corresponding config function if it exists
            for button in "${inputConfigButtonList[@]}"; do
                funcname=$button"_inputconfig_"${onlyFilename::-3}

                # if interface function is implemented
                if fn_exists "$funcname"; then

                    inputName=$(getInputAttribute "$button" "name")
                    inputType=$(getInputAttribute "$button" "type")
                    inputID=$(getInputAttribute "$button" "id")
                    inputValue=$(getInputAttribute "$button" "value")

                    # if input was defined
                    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName='$deviceName']/input[@name='$inputName'])" "$home"/.emulationstation/es_temporaryinput.cfg) -ne 0 ]]; then
                        "$funcname" "$deviceType" "$deviceName" "$inputName" "$inputType" "$inputID" "$inputValue"
                    fi
                fi
            done

            # at the end, the onleave_inputconfig_X function is called
            funcname="onleave_inputconfig_"${onlyFilename::-3}

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

###### main ######

user="$SUDO_USER"
[[ -z "$user" ]] && user=$(id -un)
home="$(eval echo ~$user)"

inputconfiguration
