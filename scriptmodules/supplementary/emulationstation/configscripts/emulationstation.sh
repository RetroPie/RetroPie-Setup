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
    local device_type=$1
    local device_name=$2

    local es_conf="$home/.emulationstation/es_input.cfg"

    mkdir -p "$home/.emulationstation"

    if [[ ! -f "$es_conf" ]]; then
        echo "<inputList />" >"$es_conf"
    else
        cp "$es_conf" "$es_conf.bak"
    fi

    # make sure that device exists
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName=\"$device_name\"])" "$es_conf") -eq 0 ]]; then
        xmlstarlet ed -L -s "/inputList" -t elem -n newInputConfig -v "" \
            -i //newInputConfig -t attr -n "type" -v "$device_type" \
            -i //newInputConfig -t attr -n "deviceName" -v "$device_name" \
            -r //newInputConfig -v inputConfig \
            "$es_conf"
    else
        xmlstarlet ed -L \
            -u "/inputList/inputConfig[@deviceName=\"$device_name\"]/@device_type" -v "$device_type" \
            -d "/inputList/inputConfig[@deviceName=\"$device_name\"]/@deviceGUID" \
            "$es_conf"
    fi
}

function map_emulationstation_joystick() {
    local device_type="$1"
    local device_name="$2"
    local input_name="$3"
    local input_type="$4"
    local input_id="$5"
    local input_value="$6"

    local key
    case "$input_name" in
        leftbottom)
            key="pageup"
            ;;
        rightbottom)
            key="pagedown"
            ;;
        up|right|down|left|a|b|start|select)
            key="$input_name"
            ;;
        *)
            return
            ;;
    esac

    local es_conf="$home/.emulationstation/es_input.cfg"

    # add or update element
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputConfig[@deviceName=\"$device_name\"]/input[@name=\"$key\"])" "$es_conf") -eq 0 ]]; then
        xmlstarlet ed -L -s "/inputList/inputConfig[@deviceName=\"$device_name\"]" -t elem -n newinput -v "" \
            -i //newinput -t attr -n "name" -v "$key" \
            -i //newinput -t attr -n "type" -v "$input_type" \
            -i //newinput -t attr -n "id" -v "$input_id" \
            -i //newinput -t attr -n "value" -v "$input_value" \
            -r //newinput -v input \
            "$es_conf"
    else  # if device already exists, update it
        xmlstarlet ed -L \
            -u "/inputList/inputConfig[@deviceName=\"$device_name\"]/input[@name=\"$key\"]/@type" -v "$input_type" \
            -u "/inputList/inputConfig[@deviceName=\"$device_name\"]/input[@name=\"$key\"]/@id" -v "$input_id" \
            -u "/inputList/inputConfig[@deviceName=\"$device_name\"]/input[@name=\"$key\"]/@value" -v "$input_value" \
            "$es_conf"
    fi
}

function onstart_emulationstation_keyboard() {
    onstart_emulationstation_joystick "$@"
}

function map_emulationstation_keyboard() {
    map_emulationstation_joystick "$@"
}
