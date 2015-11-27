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

    # write temp file header
    echo "; ${device_name}_START " > /tmp/reicasttempconfig.cfg
    echo "[${device_name}]" >> /tmp/reicasttempconfig.cfg
    iniConfig " = " "" "/tmp/reicasttempconfig.cfg"
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
            keys=("DPad_Up")
            ;;
        down)
            keys=("DPad_Down")
            ;;
        left)
            keys=("DPad_Left")
            ;;
        right)
            keys=("DPad_Right")
            ;;
        a)
            keys=("Btn_B")
            ;;
        b)
            keys=("Btn_A")
            ;;
        x)
            keys=("Btn_Y")
            ;;
        y)
            keys=("Btn_X")
            ;;
        leftbottom)
            keys=("Axis_LT")
            ;;
        rightbottom)
            keys=("Axis_RT")
            ;;
        lefttop)
            keys=("DPad2_Left")
            ;;
        righttop)
            keys=("DPad2_Right")
            ;;
        start)
            keys=("Btn_Start")
            ;;
        select)
            keys=("Quit")
            ;;
        leftanalogleft)
            keys=("Axis_X")
            ;;
        leftanalogright)
            keys=("Axis_X")
            ;;
        leftanalogup)
            keys=("Axis_Y")
            ;;
        leftanalogdown)
            keys=("Axis_Y")
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
                if [[ "$key" == "DPad2_Left" ]] ; then
                    iniSet "button.$input_id" "Axis_LT"
                elif [[ "$key" == "DPad2_Right" ]] ; then
                    iniSet "button.$input_id" "Axis_RT"
                elif [[ "$key" == "DPad_Up" || "$key" == "DPad_Down" ]]; then
                    iniSet "axis.$input_id" "Axis_Y" 
                elif [[ "$key" == "DPad_Right" || "$key" == "DPad_Left" ]]; then
                    iniSet "axis.$input_id" "Axis_X" 
                elif [[ "$key" == *Axis* ]] ; then
                    iniSet "axis.$input_id" "${key}" 
                fi
                ;;
            hat)
                ;;
            *)
                if [[ "$key" == "Axis_LT" ]] ; then
                    iniSet "button.$input_id" "DPad2_Left"
                elif [[ "$key" == "Axis_RT" ]] ; then
                    iniSet "button.$input_id" "DPad2_Right"
                elif [[ "$key" == "Axis_X" || "$key" == "Axis_Y" ]] ; then
                else
                    iniSet "button.$input_id" "$key"
                fi
                ;;
        esac
    done
}

function onend_reicast_joystick() {
    local device_type=$1
    local device_name=$2

    echo "; ${device_name}_END " >> /tmp/reicasttempconfig.cfg
    echo "" >> /tmp/reicasttempconfig.cfg

    # abort if old device config cannot be deleted.
    local file="/home/pi/.reicast/emu.cfg"
    if [[ ! -d "/home/pi/.reicast" ]]; then
        mkdir /home/pi/.reicast
    fi
    if [[ -f "$file" ]]; then
        # backup current config file
        cp "$file" "${file}.bak"
        # if reicast did not run frames are there
        if grep -q "${device_name}_END" "$file" ; then
            sed -i /"${device_name}_START"/,/"${device_name}_END"/d "$file"
        # reicast removes frames after first run but adds axis.31
        else
            sed -i /"${device_name}"/,/"axis.31="/d "$file"
        fi
        if grep -q "$device_name" "$file" ; then
            rm /tmp/reicasttempconfig.cfg
            return
        fi
    fi

    # read temp device configuration and append to emu.cfg
    cat /tmp/reicasttempconfig.cfg >> "$file"
    rm /tmp/reicasttempconfig.cfg
}
