#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_dolphin_joystick() {
    # write a temp file that will become the Controller Profile
    iniConfig " = " "" "/tmp/gctempconfig.cfg"
    cat <<EOF > /tmp/gctempconfig.cfg
[Profile]
Device = evdev/0/${DEVICE_NAME}
EOF
}


function map_dolphin_joystick() {
    local file="/tmp/gctempconfig.cfg"
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local keys
    local dir
    case "$input_name" in
        up)
            keys=("D-Pad/Up")
            dir=("Up")
            ;;
        down)
            keys=("D-Pad/Down")
            dir=("Down")
            ;;
        left)
            keys=("D-Pad/Left")
            dir=("Left")
            ;;
        right)
            keys=("D-Pad/Right")
            dir=("Right")
            ;;
        b)
            keys=("Buttons/B")
            ;;
        y)
            keys=("Buttons/Y")
            ;;
        a)
            keys=("Buttons/A")
            ;;
        x)
            keys=("Buttons/X")
            ;;
        leftbottom|leftshoulder)
            keys=("Triggers/L")
            ;;
        rightbottom|rightshoulder)
            keys=("Triggers/R")
            ;;
        righttop|righttrigger)
            keys=("Buttons/Z")
            ;;
        start)
            keys=("Buttons/Start")
            ;;
        leftanalogleft)
            keys=("Main Stick/Left")
            dir=("Left")
            ;;
        leftanalogright)
            keys=("Main Stick/Right")
            dir=("Right")
            ;;
        leftanalogup)
            keys=("Main Stick/Up")
            dir=("Up")
            ;;
        leftanalogdown)
            keys=("Main Stick/Down")
            dir=("Down")
            ;;
        rightanalogleft)
            keys=("C-Stick/Left")
            dir=("Left")
            ;;
        rightanalogright)
            keys=("C-Stick/Right")
            dir=("Right")
            ;;
        rightanalogup)
            keys=("C-Stick/Up")
            dir=("Up")
            ;;
        rightanalogdown)
            keys=("C-Stick/Down")
            dir=("Down")
            ;;
        hotkeyenable)
            keys=("Hotkey")
            ;;
        *)
            return
            ;;
    esac

    local key
    local value
    #iniConfig " = " "" "/tmp/gckeys.cfg"
    for key in "${keys[@]}"; do
        # read key value. Axis takes two key/axis values.
        iniGet "$key"
        case "$input_type" in
            axis)
                # key "X/Y Axis" needs different button naming
                if [[ "$key" == *Axis* ]]; then
                    # if there is already a "-" axis add "+" axis value
                    if [[ "$ini_value" == *\(* ]]; then
                        value="${ini_value}\`Axis ${input_id}+\`"
                    # if there is already a "+" axis add "-" axis value
                    elif [[ "$ini_value" == *\)* ]]; then
                        value="\`Axis ${input_id}-\`, ${ini_value}"
                    # if there is no ini_value add "+" axis value
                    elif [[ "$input_value" == "1" ]]; then
                        value="\`Axis ${input_id}+\`"
                    else
                        value="\`Axis ${input_id}-\`"
                    fi
                elif [[ "$input_value" == "1" ]]; then
                    value="\`Axis ${input_id}+\` ${ini_value}"
                else
                    value="\`Axis ${input_id}-\` ${ini_value}"
                fi
                ;;
            hat)
                if [[ "$key" == *Axis* ]]; then
                    if [[ "$ini_value" == *\(* ]]; then
                        value="${ini_value}\`Hat ${input_id} ${dir}\`"
                    elif [[ "$ini_value" == *\)* ]]; then
                        value="\`Hat ${input_id} ${dir}\`, ${ini_value}"
                    elif [[ "$dir" == "Up" || "$dir" == "Left" ]]; then
                        value="\`Hat ${input_id} ${dir}\`"
                    elif [[ "$dir" == "Right" || "$dir" == "Down" ]]; then
                        value="\`${dir}\`"
                    fi
                else
                    if [[ -n "$dir" ]]; then
                        value="\`Hat ${input_id} ${dir}\` ${ini_value}"
                    fi
                fi
                ;;
            *)
                if [[ "$key" == *Axis* ]]; then
                    if [[ "$ini_value" == *\(* ]]; then
                        value="${ini_value}\`Button ${input_id}\`"
                    elif [[ "$ini_value" == *\)* ]]; then
                        value="\`Button ${input_id}\`, ${ini_value}"
                    elif [[ "$dir" == "Up" || "$dir" == "Left" ]]; then
                        value="\`Button ${input_id}\`"
                    elif [[ "$dir" == "Right" || "$dir" == "Down" ]]; then
                        value="\`${input_id}\`"
                    fi
                else
                    value="\`Button ${input_id}\` ${ini_value}"
                fi
                ;;
        esac

        iniSet "$key" "$value"
    done
}

function onend_dolphin_joystick() {
    local axis
    local dpad_axis

    # Check if any Main Stick entries exist
    if ! grep -q "Main Stick" /tmp/gctempconfig.cfg; then
        # List of D-Pad to Main Stick mappings
        declare -A axis_mapping=(
            ["D-Pad/Up"]="Main Stick/Up"
            ["D-Pad/Down"]="Main Stick/Down"
            ["D-Pad/Left"]="Main Stick/Left"
            ["D-Pad/Right"]="Main Stick/Right"
        )

        # Loop through the D-Pad mappings and rename them
        for dpad_axis in "${!axis_mapping[@]}"; do
            # Check if the D-Pad entry exists
            if grep -q "$dpad_axis" /tmp/gctempconfig.cfg; then
                # Get the value for the D-Pad entry
                iniGet "$dpad_axis"
                ini_value="$ini_value"

                # Set the corresponding Main Stick entry
                iniSet "${axis_mapping[$dpad_axis]}" "$ini_value"
                iniDel "$dpad_axis"  # Remove the D-Pad entry
            fi
        done
    fi
    
    # Map generic Stick cali
    cat <<EOF >> /tmp/gctempconfig.cfg
Main Stick/Calibration = 100.00 141.42 100.00 141.42 100.00 141.42 100.00 141.42
C-Stick/Calibration = 100.00 141.42 100.00 141.42 100.00 141.42 100.00 141.42
EOF
    
    # disable any auto configs for the same device to avoid duplicates
    local output_file
    local dir="$configdir/gc/Config/Profiles/GCPad"
    while read -r output_file; do
        mv "$output_file" "$output_file.bak"
    done < <(grep -Fl "\"$DEVICE_NAME\"" "$dir/"*.ini 2>/dev/null)

    # sanitise filename
    output_file="${DEVICE_NAME//[:><?\"\/\\|*]/}.ini"

    if [[ -f "$dir/$output_file" ]]; then
        mv "$dir/$output_file" "$dir/$output_file.bak"
    fi
    mv "/tmp/gctempconfig.cfg" "$dir/$output_file"
}
