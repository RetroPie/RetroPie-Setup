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
    local file

    case "$DEVICE_NAME" in
        "Xbox 360 Controller (xpad driver)")
            file="$configdir/dreamcast/mappings/controller_xpad.cfg"
            ;;
        "Xbox 360 Controller (xboxdrv userspace driver)")
            file="$configdir/dreamcast/mappings/controller_xboxdrv.cfg"
            ;;
        *)
            file="$configdir/dreamcast/mappings/controller_${DEVICE_NAME// /}.cfg"
            ;;
    esac

    # create mapping dir if necessary.
    mkdir -p "$configdir/dreamcast/mappings"

    # remove old config file
    rm -f "$file"

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
    iniSet "mapping_name" "$DEVICE_NAME"
}

function map_reicast_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

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
        leftbottom|leftshoulder)
            keys=("btn_trigger_left")
            ;;
        rightbottom|rightshoulder)
            keys=("btn_trigger_right")
            ;;
        lefttop|lefttrigger)
            keys=("axis_trigger_left")
            ;;
        righttop|righttrigger)
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
                    case "$DEVICE_NAME" in
                        "Xbox 360 Controller (xpad driver)"|"Xbox 360 Controller (xboxdrv userspace driver)"|"Microsoft X-Box 360 pad"|"Xbox Gamepad (userspace driver)"|"Xbox 360 Wireless Receiver (XBOX)"|"Microsoft X-Box One pad"|"Microsoft X-Box pad (Japan)"|"Chinese-made Xbox Controller")
                            if [[ "$input_id" -gt 2 && "$input_id" -lt 5 ]]; then
                                input_id=$(($input_id+13))
                            fi
                            ;;
                    esac
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
                    # workaround for specific controller button mismatch
                    case "$DEVICE_NAME" in
                        "Xbox 360 Controller (xpad driver)"|"Xbox 360 Controller (xboxdrv userspace driver)"|"Microsoft X-Box 360 pad"|"Xbox Gamepad (userspace driver)"|"Xbox 360 Wireless Receiver (XBOX)"|"Microsoft X-Box One pad"|"Microsoft X-Box pad (Japan)"|"Chinese-made Xbox Controller")
                            if [[ "$input_id" -lt "294" ]]; then
                                input_id=$(($input_id+16))
                            else
                                input_id=$(($input_id+20))
                            fi
                            ;;
                    esac
                    iniSet "$key" "$input_id"
                fi
                ;;
        esac
    done
}

function onend_reicast_joystick() {
    local file

    case "$DEVICE_NAME" in
        "Xbox 360 Controller (xpad driver)")
            file="$configdir/dreamcast/mappings/controller_xpad.cfg"
            ;;
        "Xbox 360 Controller (xboxdrv userspace driver)")
            file="$configdir/dreamcast/mappings/controller_xboxdrv.cfg"
            ;;
        *)
            file="$configdir/dreamcast/mappings/controller_${DEVICE_NAME// /}.cfg"
            ;;
    esac

    # add empty end line
    echo "" >> "$file"
}
