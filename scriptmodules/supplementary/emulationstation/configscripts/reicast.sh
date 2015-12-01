#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_reicast_joystick() {
    local device_type=$1
    local device_name=$2
    local file="/home/pi/.reicast/mappings/controller_${device_name}.cfg"
    file=${file// /}

    # create mapping dir if necessary.
    if [[ ! -d "/home/pi/.reicast" ]]; then
        mkdir /home/pi/.reicast
    fi
    if [[ ! -d "/home/pi/.reicast/mappings" ]]; then
        mkdir /home/pi/.reicast/mappings
    fi

    # remove old config file
    if [[ -f "$file" ]]; then
        rm "$file"
    fi

    # write config template
    cat > "$file" << _EOF_
[emulator]
mapping_name =
btn_escape =

[dreamcast]
btn_a =
btn_b =
btn_c =
btn_d =
btn_x =
btn_y =
btn_z =
btn_start =
btn_dpad1_left =
btn_dpad1_right =
btn_dpad1_up =
btn_dpad1_down =
btn_dpad2_left =
btn_dpad2_right =
btn_dpad2_up =
btn_dpad2_down =
axis_x =
axis_y =
axis_trigger_left =
axis_trigger_right =

[compat]
btn_trigger_left =
btn_trigger_right =
axis_dpad1_x =
axis_dpad1_y =
axis_dpad2_x =
axis_dpad2_y =
axis_x_inverted =
axis_y_inverted =
axis_trigger_left_inverted =
axis_trigger_right_inverted =
_EOF_

    # write temp file header
    iniConfig " = " "" "$file"
    iniSet "mapping_name" "$device_name"
}

function map_reicast_joystick() {
    local device_type="$1"
    local device_name="$2"
    local input_name="$3"
    local input_type="$4"
    local input_id="$5"
    local input_value="$6"

    local keys
    local dir
    case "$input_name" in
        up)
            keys=("btn_dpad1_up")
            ;;
        down)
            keys=("btn_dpad1_down")
            ;;
        left)
            keys=("btn_dpad1_left")
            ;;
        right)
            keys=("btn_dpad1_right")
            ;;
        a)
            keys=("btn_b")
            ;;
        b)
            keys=("btn_a")
            ;;
        x)
            keys=("btn_y")
            ;;
        y)
            keys=("btn_x")
            ;;
        leftbottom)
            keys=("btn_trigger_left")
            ;;
        rightbottom)
            keys=("btn_trigger_right")
            ;;
        lefttop)
            keys=("axis_trigger_left")
            ;;
        righttop)
            keys=("axis_trigger_right")
            ;;
        start)
            keys=("btn_start")
            ;;
        select)
            keys=("btn_escape")
            ;;
        leftanalogleft)
            keys=("axis_x")
            ;;
        leftanalogright)
            keys=("axis_x")
            ;;
        leftanalogup)
            keys=("axis_y")
            ;;
        leftanalogdown)
            keys=("axis_y")
            ;;
        rightanalogleft)
            keys=("axis_dpad1_x")
            ;;
        rightanalogright)
            keys=("axis_dpad1_x")
            ;;
        rightanalogup)
            keys=("axis_dpad1_y")
            ;;
        rightanalogdown)
            keys=("axis_dpad1_y")
            ;;
        *)
            return
            ;;
    esac

    local key
    local value
    for key in "${keys[@]}"; do
        # read key value. Axis takes two key/axis values.
        case "$input_type" in
            axis) 
                # key "X/Y Axis" needs different button naming
                if [[ "$key" == "btn_trigger_left" ]] ; then
                    iniSet "axis_trigger_left" "$input_id"
                    iniSet "axis_trigger_left_inverted" "no"
                elif [[ "$key" == "btn_trigger_right" ]] ; then
                    iniSet "axis_trigger_right" "$input_id"
                    iniSet "axis_trigger_right_inverted" "no"
                elif [[ "$key" == "btn_dpad1_up" || "$key" == "btn_dpad1_down" ]]; then
                    iniSet "axis_y" "$input_id"
                    iniSet "axis_y_inverted" "no"
                elif [[ "$key" == "btn_dpad1_left" || "$key" == "btn_dpad1_right" ]]; then
                    iniSet "axis_x" "$input_id"
                    iniSet "axis_x_inverted" "no"
                elif [[ "$key" == *axis* ]] ; then
                    iniSet "${key}" "$input_id"
                    iniSet "${key}_inverted" "no"
                fi
                ;;
            hat)
                ;;
            *)
                if [[ "$key" != *axis* ]] ; then
                    # input_id must be recalculated: 288d = button 0
                    input_id=$(($input_id+288))
                    iniSet "$key" "$input_id"
                fi
                ;;
        esac
    done
}

function onend_reicast_joystick() {
    local device_type=$1
    local device_name=$2
    local file="/home/pi/.reicast/mappings/controller_${device_name}.cfg"
    file=${file// /}
    
    # add empty end line
    echo "" >> "$file"
}
