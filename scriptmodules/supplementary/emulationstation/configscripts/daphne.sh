#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function check_daphne() {
    [[ ! -d "$configdir/daphne/" ]] && return 1
    return 0
}

function onstart_daphne_joystick() {
    local -r mapping_file="$configdir/daphne/dapinput.ini"
    local -r force_joy_file="$configdir/daphne/dapinput-forcejoy.ini"
    local -r force_key_file="$configdir/daphne/dapinput-forcekey.ini"

    if [[ ! -f "$mapping_file" ]]; then
        cat > "$mapping_file" << _EOF_
# Daphne custom keyboard and joystick mapping
#
# Each input is mapped to 2 keyboard keys and one joystick button.
# A joystick's first analog stick is also automatically mapped.
#
# The first two numbers are SDL keyboard codes (or 0 for "none")
# Find keyboard codes here:
# http://www.daphne-emu.com/mediawiki/index.php/KeyList
#
# The third number is the joystick button code (or 0 for "none")
# Since 0 is reserved for special meaning, joystick button 0 is identified
# as 1 here.  Button 1 is identified as 2, and so on.
#
# Find the button you want to map by running:
# jstest /dev/input/js0

[KEYBOARD]
KEY_UP = 273 114 5
KEY_DOWN = 274 102 7
KEY_LEFT = 276 100 8
KEY_RIGHT = 275 103 6
KEY_BUTTON1 = 306 97 14
KEY_BUTTON2 = 308 115 15
KEY_BUTTON3 = 32 113 16
KEY_START1 = 49 0 4
KEY_START2 = 50 0 0
KEY_COIN1 = 53 0 1
KEY_COIN2 = 54 0 0
KEY_SKILL1 = 304 119 0
KEY_SKILL2 = 122 105 0
KEY_SKILL3 = 120 107 0
KEY_SERVICE = 57 0 0
KEY_TEST = 283 0 0
KEY_RESET = 284 0 0
KEY_SCREENSHOT = 293 0 0
KEY_QUIT = 27 113 17
END
_EOF_
    fi

    if [[ ! -f "$force_joy_file" ]]; then
        cat > "$force_joy_file" << _EOF_
# Daphne custom joystick mapping
#
# Any inputs defined below will map a joystick button to
# Daphne input, regardless of remapping that occurs in emulationstation.
#
# Each input is mapped to 1 joystick button (or 0 for "none")
#
# Find joystick button codes by running:
# $ jstest /dev/input/js0
# and ADDING ONE to the button code you want.
#
# Example: Quit will always be js button 14
# KEY_QUIT = 15
#
# (Place all entries after [KEYBOARD])

[KEYBOARD]
END
_EOF_
    fi

    if [[ ! -f "$force_key_file" ]]; then
        cat > "$force_key_file" << _EOF_
# Daphne custom keyboard mapping
#
# Any inputs defined below will map keyboard keys to
# Daphne input, regardless of remapping that occurs in emulationstation.
#
# Each input is mapped to 2 keyboard key codes (or 0 for "none")
#
# Find keyboard codes here:
# http://www.daphne-emu.com/mediawiki/index.php/KeyList
#
# Example: Quit will always be key [Esc] or [Q]
# KEY_QUIT = 27 113
#
# (Place all entries after [KEYBOARD])

[KEYBOARD]
END
_EOF_
    fi
}

function map_daphne_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local -r mapping_file="$configdir/daphne/dapinput.ini"
    local -r force_joy_file="$configdir/daphne/dapinput-forcejoy.ini"
    local -r force_key_file="$configdir/daphne/dapinput-forcekey.ini"

    local key
    case "$input_name" in
        up)
            key="KEY_UP"
            ;;
        down)
            key="KEY_DOWN"
            ;;
        left)
            key="KEY_LEFT"
            ;;
        right)
            key="KEY_RIGHT"
            ;;
        a)
            key="KEY_BUTTON1"
            ;;
        b)
            key="KEY_BUTTON2"
            ;;
        x)
            key="KEY_BUTTON3"
            ;;
        y)
            key="KEY_COIN1"
            ;;
        leftbottom)
            key="KEY_SKILL1"
            ;;
        rightbottom)
            key="KEY_SKILL2"
            ;;
        lefttop)
            key="KEY_SKILL3"
            ;;
        righttop)
            key="KEY_SERVICE"
            ;;
        start)
            key="KEY_START1"
            ;;
        select)
            key="KEY_QUIT"
            ;;
        *)
            return
            ;;
    esac

    local key_regex="^$key = (.*) (.*)\$"
    local button_regex="^$key = (.*)\$"
    local full_regex="^$key = (.*) (.*) (.*)\$"
    local line
    local key1
    local key2
    local button

    # See if this key is specified in the override file...
    while read -r line; do
        if [[ "$line" =~ $key_regex ]]; then
            key1="${BASH_REMATCH[1]}"
            key2="${BASH_REMATCH[2]}"
        fi
    done < "$force_key_file"

    # ...otherwise, use the defaults file.
    if [[ -z "$key1" || -z "$key2" ]]; then
        echo "Keymap not found in $force_key_file"
        while read -r line; do
            if [[ "$line" =~ $full_regex ]]; then
                key1="${BASH_REMATCH[1]}"
                key2="${BASH_REMATCH[2]}"
            fi
        done < "$mapping_file"
    fi

    # See if this button is specified in the override file...
    while read -r line; do
        if [[ "$line" =~ $button_regex ]]; then
            button="${BASH_REMATCH[1]}"
        fi
    done < "$force_joy_file"

    # ...otherwise, use the config sent to this function.
    if [[ -z "$button" ]]; then
        while read -r line; do
            if [[ "$line" =~ $key_regex ]]; then
                button=$((input_id+1))
            fi
        done < "$mapping_file"
    fi

    # Write new button config
    sed -i "s/^$key = .* .* .*\$/$key = $key1 $key2 $button/g" "$mapping_file"
}