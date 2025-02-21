#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# This input configuration script will create a SDL(2) GameController mapping string based on the user's choices (see [1] for the format).
# The mapping is a comma (,) separated string of 'parameter:value' used by SDL to use the GameController.
# SDL2 comes with it's own list of built-in mappings, defined in [2], which covers most of the well-known gamepads, but offers the ability
# to:
# - load additional mappings programmatically from a file using [3].
#   This is the approach used by emulators that include an additional `gamecontrollerdb.txt` to allow extending the default SDL gamecontroller mapping database.
# - load additional mappings from the `SDL_GAMECONTROLLERCONFIG` environment variable, which should contain newline delimited list of mappings (see [4])
# - load additional mappings from the file pointed with `SDL_GAMECONTROLLERCONFIG_FILE` environment variable, containing newline delimited list of mapping (see [5]). Available only from SDL 2.0.22.
#
# The script will produce a mapping string for a configured joystick in EmulationStation, then store the result in:
#   /opt/retropie/configs/all/sdl2_gamecontrollerdb.txt
# This file can then be consulted by `runcommand` and the new mappings referenced via SDL2 hints.
#
# Notes:
#   - this script will not replace the default/built-in SDL mappings
#   - gamecontroller naming sanitization is not identical to SDL name mapping routines, but that doesn't affect functionality
#
# Ref:
# [1] https://wiki.libsdl.org/SDL2/SDL_GameControllerAddMapping
# [2] https://github.com/libsdl-org/SDL/blob/SDL2/src/joystick/SDL_gamecontrollerdb.h
# [3] https://wiki.libsdl.org/SDL2/SDL_GameControllerAddMappingsFromFile
# [4] https://wiki.libsdl.org/SDL2/SDL_HINT_GAMECONTROLLERCONFIG
# [5] https://wiki.libsdl.org/SDL2/SDL_HINT_GAMECONTROLLERCONFIG_FILE

function onstart_sdl2_joystick() {
    # save the intermediary mappings into a temporary file
    local temp_file
    temp_file="$(_temp_file_sdl2)"
    : > "$temp_file"
}

function map_sdl2_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"
    local input_temp_map="$(_temp_file_sdl2)"

    # map ES input name => SDL Gamecontroller mapping label
    declare -A input_map=(
                      [up]="dpup"
                    [down]="dpdown"
                    [left]="dpleft"
                   [right]="dpright"
                       [a]="a"
                       [b]="b"
                       [x]="x"
                       [y]="y"
                   [start]="start"
                  [select]="back"

            [hotkeyenable]="guide"

            [leftshoulder]="leftshoulder"
             [lefttrigger]="lefttrigger"
           [rightshoulder]="rightshoulder"
            [righttrigger]="righttrigger"

               [leftthumb]="leftstick"
         [leftanalogright]="leftx"
          [leftanalogdown]="lefty"

              [rightthumb]="rightstick"
        [rightanalogright]="rightx"
         [rightanalogdown]="righty"

                  [pageup]="rightshoulder"
                [pagedown]="leftshoulder"
    )
    local sdl2_mapped_input

    sdl2_mapped_input=${input_map[$input_name]}

    # when the SDL mapped action/input is not defined skip the mapping
    [[ -z "$sdl2_mapped_input" ]] && return

    case "$input_type" in
       axis)
           if [[ "$input_value" == "-1" ]]; then
               echo "$sdl2_mapped_input:-a${input_id}" >> "$input_temp_map"
           else
               echo "$sdl2_mapped_input:+a${input_id}" >> "$input_temp_map"
           fi
           ;;
       hat)
           echo "$sdl2_mapped_input:hat${input_id}.${input_value}" >> "$input_temp_map"
           ;;
       button)
           echo "$sdl2_mapped_input:b${input_id}" >> "$input_temp_map"
           ;;
       *)
           ;;
     esac
}

function onend_sdl2_joystick() {
    # check whether SDL2 already has a mapping for this GUID
    if [[ "$(_check_gamepad_sdl2)" == "MAPPED" ]]; then
        echo "W: Device \"$DEVICE_NAME\" (guid: $DEVICE_GUID) is already known by SDL2, gamecontroller mapping was not created"
        return
    fi

    # gamecontroller name sanitization:
    # - replace unexpected chars with '-'
    # - trim blanks from the name (beginning/end)
    # - replace ',' with space, since ',' is a delimiter in the mapping string
    local joyname="$(echo ${DEVICE_NAME//[:><?\"\/\\|*]/-} | tr -s '[:blank:]' | tr ',' ' ')"
    local select_value
    local hotkey_value
    local mapping
    local input_temp_map
    input_temp_map="$(_temp_file_sdl2)"

    # add each mapping value and save the values for Select/Back Hotkey/Guide
    # don't add the Hotkey/Guide mapping yet
    while read m; do
       if [[ "$m" == "guide:*" ]]; then
            hotkey_value="$m";
            continue;
        fi

        if [[ "$m" == "back:*" ]]; then
            select_value="$m";
        fi

        mapping+="$m,"
     done < <(sort "$input_temp_map")

    # add the mapping for Hotkey as Guide IIF it's different than Select
    if [[ $select_value != $hotkey_value && -n "$hotkey_value" ]]; then
        mapping+="$hotkey_value,"
    fi
    local sdl_configs="$configdir/all/sdl2_gamecontrollerdb.txt"
    mapping="${DEVICE_GUID},${joyname},platform:Linux,${mapping}"

    [[ -n $__debug ]] && \
        echo "Mapping is $mapping"

    # update the mapping when it's present, otherwise append it to the file
    if grep --silent --no-messages ${DEVICE_GUID} "$sdl_configs"; then
        sed -i "s/^${DEVICE_GUID}.*$/$mapping/" "$sdl_configs"
    else
        echo "$mapping" >> "$sdl_configs"
    fi
    rm -f "$input_temp_map"
}

# function to check whether a gamepad GUID is already in SDL2's mapping list
# we need to load SDL2's GameController subsystem and query by GUID
function _check_gamepad_sdl2() {

cat << EOF > "/tmp/guid_check.py"
from sdl2 import SDL_GameControllerMappingForGUID,\
    SDL_Init,SDL_Quit,SDL_Error,\
    SDL_INIT_GAMECONTROLLER
from sdl2.joystick import SDL_JoystickGetGUIDFromString

if SDL_Init(SDL_INIT_GAMECONTROLLER) < 0:
    exit(2)

guid_str=b"${DEVICE_GUID}"
guid = SDL_JoystickGetGUIDFromString(guid_str)
map = SDL_GameControllerMappingForGUID(guid)
SDL_Quit()

if map is not None:
    exit(0)

exit(1)
EOF
    python3 /tmp/guid_check.py 1>/dev/null 2>&1 && echo "MAPPED"
    rm -f "/tmp/guid_check.py"
}

function _temp_file_sdl2() {
    echo "/tmp/sdl2temp.txt"
}
