#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_emulationstation_joystick() {
    local es_conf="$home/.emulationstation/es_input.cfg"

    mkdir -p "$home/.emulationstation"

    if [[ ! -f "$es_conf" ]]; then
        echo "<inputList />" >"$es_conf"
    else
        cp "$es_conf" "$es_conf.bak"
    fi

    # look for existing inputConfig in config by GUID
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceGUID=\"$DEVICE_GUID\"])" "$es_conf") -eq 0 ]]; then
        # if not found by GUID, look for inputConfig with deviceName only
        if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName=\"$DEVICE_NAME\"][not(@deviceGUID)])" "$es_conf") -eq 0 ]]; then
            # insert new inputConfig entry
            xmlstarlet ed -L -s "/inputList" -t elem -n newInputConfig -v "" \
                -i //newInputConfig -t attr -n "type" -v "$DEVICE_TYPE" \
                -i //newInputConfig -t attr -n "deviceName" -v "$DEVICE_NAME" \
                -i //newInputConfig -t attr -n "deviceGUID" -v "$DEVICE_GUID" \
                -r //newInputConfig -v inputConfig \
                "$es_conf"
        else
            # add deviceGUID to inputConfig
            xmlstarlet ed -L \
                -i "/inputList/inputConfig[@deviceName=\"$DEVICE_NAME\"]" -t attr -n "deviceGUID" -v "$DEVICE_GUID" \
                "$es_conf"
        fi
    fi
}

function map_emulationstation_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local key
    case "$input_name" in
        leftbottom|leftshoulder)
            key="pageup"
            ;;
        rightbottom|rightshoulder)
            key="pagedown"
            ;;
        up|right|down|left|start|select|x|y|leftanalogup|leftanalogright|leftanalogdown|leftanalogleft|rightanalogup|rightanalogright|rightanalogdown|rightanalogleft)
            key="$input_name"
            ;;
        a)
            key="$input_name"
            getAutoConf es_swap_a_b && key="b"
            ;;
        b)
            key="$input_name"
            getAutoConf es_swap_a_b && key="a"
            ;;
        *)
            return
            ;;
    esac
    local es_conf="$home/.emulationstation/es_input.cfg"

    # add or update element
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceGUID=\"$DEVICE_GUID\"]/input[@name=\"$key\"])" "$es_conf") -eq 0 ]]; then
        xmlstarlet ed -L -s "/inputList/inputConfig[@deviceGUID=\"$DEVICE_GUID\"]" -t elem -n newinput -v "" \
            -i //newinput -t attr -n "name" -v "$key" \
            -i //newinput -t attr -n "type" -v "$input_type" \
            -i //newinput -t attr -n "id" -v "$input_id" \
            -i //newinput -t attr -n "value" -v "$input_value" \
            -r //newinput -v input \
            "$es_conf"
    else  # if device already exists, update it
        xmlstarlet ed -L \
            -u "/inputList/inputConfig[@deviceGUID=\"$DEVICE_GUID\"]/input[@name=\"$key\"]/@type" -v "$input_type" \
            -u "/inputList/inputConfig[@deviceGUID=\"$DEVICE_GUID\"]/input[@name=\"$key\"]/@id" -v "$input_id" \
            -u "/inputList/inputConfig[@deviceGUID=\"$DEVICE_GUID\"]/input[@name=\"$key\"]/@value" -v "$input_value" \
            "$es_conf"
    fi
}

function onstart_emulationstation_keyboard() {
    onstart_emulationstation_joystick "$@"
}

function map_emulationstation_keyboard() {
    map_emulationstation_joystick "$@"
}

function onstart_emulationstation_cec() {
    onstart_emulationstation_joystick "$@"
}

function map_emulationstation_cec() {
    map_emulationstation_joystick "$@"
}
