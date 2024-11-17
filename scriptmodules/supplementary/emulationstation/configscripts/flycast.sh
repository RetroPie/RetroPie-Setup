#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_flycast_joystick() {
    # Save the intermediary mappings into a temporary file
    truncate --size 0 /tmp/flycast-input-analog.ini
    truncate --size 0 /tmp/flycast-input-digital.ini
    truncate --size 0 /tmp/flycast-input-combo.ini
}

function map_flycast_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    # map from 'es_input_name' to 'flycast_input_or_action_name'
    declare -A input_map=(
                      [up]="btn_dpad1_up"
                    [down]="btn_dpad1_down"
                    [left]="btn_dpad1_left"
                   [right]="btn_dpad1_right"
                       [a]="btn_a"
                       [b]="btn_b"
                       [x]="btn_x"
                       [y]="btn_y"
                   [start]="btn_start"

            [hotkeyenable]="btn_hotkey"

            [leftshoulder]="btn_trigger_left"
             [lefttrigger]="btn_trigger2_left"
           [rightshoulder]="btn_trigger_right" 
            [righttrigger]="btn_trigger2_right"

          [leftanalogleft]="btn_analog_left"
         [leftanalogright]="btn_analog_right"
            [leftanalogup]="btn_analog_up"
          [leftanalogdown]="btn_analog_down"

         [rightanalogleft]="axis2_left"
        [rightanalogright]="axis2_right"
           [rightanalogup]="axis2_up"
         [rightanalogdown]="axis2_down"
    )
    # map between ES Hat values to Flycast's values
    declare -A hat_map=(
        [1]=256 # up
        [2]=259 # right
        [4]=257 # down
        [8]=258 # left
    )
    # map between button (as a combo) and emulator action
    declare -A combo_map=(
                [start]="btn_escape"
                    [x]="btn_menu"
         [leftshoulder]="btn_jump_state"
        [rightshoulder]="btn_quick_save"
                 [left]="btn_prev_slot"
                [right]="btn_next_slot" 
    )
    local emu_input_value
    local emu_input_name

    emu_input_name=${input_map[$input_name]}
    combo_input_name=${combo_map[$input_name]}
    # exit when the mapped action/input is not defined
    [[ -z "$emu_input_name" ]] && return 

    case "$input_type" in
       axis)
           # axis are considered analog inputs
           if [[ $input_value == "-1" ]]; then
               emu_input_value="$input_id-"
           else
               emu_input_value="$input_id+"
           fi
           echo "$emu_input_value:$emu_input_name" >> /tmp/flycast-input-analog.ini
           ;; 
       hat)
           emu_input_value=${hat_map[$input_value]}
           echo "$emu_input_value:$emu_input_name" >> /tmp/flycast-input-digital.ini
           ;;
       button)
           emu_input_value="$input_id"
           echo "$emu_input_value:$emu_input_name" >> /tmp/flycast-input-digital.ini
           # we add combo/hotkey button combinations only for buttons
           [[ -n "$combo_input_name" ]] && echo "$emu_input_value:$combo_input_name:0" >> /tmp/flycast-input-combo.ini
           ;;
       *)
           ;;
     esac
}

function onend_flycast_joystick() {
    local dev_name=${DEVICE_NAME//[:><?\"\/\\|*]/-}
    local cfg="$configdir/dreamcast/mappings/SDL_${dev_name}.cfg"
    local i
    local line

    mkdir -p `dirname "$cfg"`

    # save the analog inputs first
    echo "[analog]" > "$cfg"
    i=0
    while read line; do
        echo "bind$i = $line" >> "$cfg"
        i="$((i+1))"
    done < <(sort /tmp/flycast-input-analog.ini | sort | uniq)
    echo >> "$cfg"

    # save the digital inputs
    i=0
    echo "[digital]" >> "$cfg"
    while read line; do
        # skip the hotkey_enable button, it's used only for combos
        [[ "$line" == *"hotkey"* ]] && continue
        echo "bind$i = $line" >> "$cfg"
        i="$((i+1))"
    done < <(sort /tmp/flycast-input-digital.ini | sort | uniq)
    echo  >> "$cfg"

    # add hotkey/button combos only when a 'hotkey_enable' button is present
    hotkey_val="$(grep btn_hotkey /tmp/flycast-input-digital.ini | cut -d: -f1)"
    if [[ -n "$hotkey_val" ]]; then
        echo "[combo]" >> "$cfg"
        i=0
        while read line; do
            echo "bind$i=${hotkey_val},$line" >> "$cfg"
            i="$((i+1))"
        done < <(sort /tmp/flycast-input-combo.ini)
        echo  >> "$cfg"
    fi

    # add the mapping name at the end
    echo "[emulator]" >> "$cfg"
    echo "mapping_name = $dev_name" >> "$cfg"
    echo "version = 4" >> "$cfg"
}
