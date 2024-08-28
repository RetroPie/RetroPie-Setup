#!/bin/bash

# Directory for controller profiles
profile_dir="/opt/retropie/configs/gc/Config/Profiles/GCPad"
gameid_ini_dir="/opt/retropie/configs/gc/local/GameSettings"  # Directory where GAMEID .ini files are stored
DOLPHIN_TOOL="/opt/retropie/emulators/dolphin/bin/dolphin-tool"
hotkeys_file="/opt/retropie/configs/gc/Config/Hotkeys.ini"

# Variables to hold the js profile name without the .ini extension
js_profile_name=""

# This function checks for devices in /proc/bus/input/devices that have joystick or gamepad handlers.
function find_game_controllers {
    echo "Scanning for game controllers..."

    while IFS= read -r line; do
        # Check for a new device block (starts with "I:")
        if [[ $line == I:* ]]; then
            device_name=""
            js_device=""
        fi

        # Look for a device name
        if [[ $line == N:* ]]; then
            device_name=$(echo $line | cut -d'"' -f2)
        fi

        # Check for handlers that include jsX (joystick)
        if [[ $line == *Handlers=* ]] && [[ $line == *js[0-9]* ]]; then
            js_device=$(echo $line | grep -o 'js[0-9]')
            echo "Detected Game Controller: $device_name ($js_device)"
            
            # Create the .ini file if it doesn't exist
            check_and_create_ini "$device_name"

            # If this is the first detected joystick, store the profile name
            if [[ -z "$js_profile_name" ]]; then
                js_profile_name="$device_name"
            fi
        fi
    done < /proc/bus/input/devices

    # If no joystick was found, notify the user
    if [[ -z "$js_profile_name" ]]; then
        echo "No joystick found (js0 to js4)."
    else
        echo "Using profile for: $js_profile_name"
        check_and_update_hotkeys "$js_profile_name"
    fi
}

# This function checks if an .ini file exists for a controller and creates it if not.
function check_and_create_ini {
    local controller_name="$1"
    local ini_file="$profile_dir/$controller_name.ini"
    
    # Check if the .ini file exists
    if [[ ! -f "$ini_file" ]]; then
        echo "Creating .ini file for $controller_name..."
        
        # Create the .ini file with the modified template content
        cat <<EOF > "$ini_file"
[Profile]
Device = evdev/0/$controller_name
Buttons/A = SOUTH
Buttons/B = EAST
Buttons/X = NORTH
Buttons/Y = WEST
Buttons/Z = TR2
Buttons/Start = \`START\`
Main Stick/Up = \`Axis 1-\`
Main Stick/Down = \`Axis 1+\`
Main Stick/Left = \`Axis 0-\`
Main Stick/Right = \`Axis 0+\`
Main Stick/Modifier = \`Shift\`
Main Stick/Calibration = 100.00 141.42 100.00 141.42 100.00 141.42 100.00 141.42
C-Stick/Up = \`Axis 3-\`
C-Stick/Down = \`Axis 3+\`
C-Stick/Left = \`Axis 2-\`
C-Stick/Right = \`Axis 2+\`
C-Stick/Modifier = \`Ctrl\`
C-Stick/Calibration = 100.00 141.42 100.00 141.42 100.00 141.42 100.00 141.42
Triggers/L = TL
Triggers/R = TR
D-Pad/Up = \`Axis 7-\`
D-Pad/Down = \`Axis 7+\`
D-Pad/Left = \`Axis 6-\`
D-Pad/Right = \`Axis 6+\`
EOF
        echo "Created: $ini_file"
    else
        echo ".ini file for $controller_name already exists."
    fi
}

# This function checks and updates the Hotkeys.ini file
function check_and_update_hotkeys {
    local controller_name="$1"
    local device_line="Device = evdev/0/$controller_name"
    
    # Path to Hotkeys.ini file
    local hotkeys_file="/opt/retropie/configs/gc/Config/Hotkeys.ini"
    
    # Check if the Hotkeys file exists
    if [[ ! -f "$hotkeys_file" ]]; then
        echo "Hotkeys.ini file not found: $hotkeys_file"
        return
    fi

    # Check if the correct Device line already exists
    if grep -q "^$device_line$" "$hotkeys_file"; then
        echo "The correct Device line already exists: $device_line"
    else
        # Create a backup of the file
        cp "$hotkeys_file" "$hotkeys_file.bak"

        # Use sed to:
        # 1. Remove lines starting with Device
        # 2. Add the new Device line
        # 3. Replace General/Exit line with SELECT & START
        sed -i -e '/^Device = /d' \
               -e '/^General\/Exit = /d' \
               -e '$aDevice = evdev/0/'"$controller_name" \
               -e '$aGeneral/Exit = SELECT & START' \
               "$hotkeys_file"

        echo "Updated Hotkeys.ini with the new Device line: $device_line"
    fi
}



function handle_rom_and_gameid_ini {
    local ROM="$1"
    local ROM_DIR="/home/pi/RetroPie/roms/gc/"

    # Check if the ROM file has an .m3u extension
    if [[ "${ROM##*.}" == "m3u" ]]; then
        if [[ -f "$ROM" ]]; then
            # Read the first non-comment, non-empty line of the .m3u file
            local M3U_ROM=$(grep -m 1 -v '^#' "$ROM" | head -n 1)
            
            if [[ -n "$M3U_ROM" ]]; then
                # Append the ROM filename from the .m3u to the fixed directory path
                ROM="${ROM_DIR}${M3U_ROM}"
                
                # Check if the constructed ROM path exists
                if [[ ! -f "$ROM" ]]; then
                    echo "Error: The ROM file referenced in the .m3u file does not exist at $ROM."
                    return 1
                fi
            else
                echo "Error: The .m3u file is empty or contains only comments."
                return 1
            fi
        else
            echo "Error: The .m3u file does not exist."
            return 1
        fi
    fi

    # Run the Dolphin tool and capture the output using the (potentially updated) ROM file
    local OUTPUT=$($DOLPHIN_TOOL header -i "$ROM")

    # Extract GAMEID
    local gameid=$(echo "$OUTPUT" | grep "Game ID:" | awk '{print $3}')
    
    # Path to GAMEID.ini
    local gameid_ini="$gameid_ini_dir/$gameid.ini"

    # Check if the js profile name is set
    if [[ -z "$js_profile_name" ]]; then
        echo "No controller profile found for js0 or any fallback. Skipping GAMEID.ini update."
        return
    fi

    # Initialize flags
    local controls_section_exists=false
    local padprofile_exists=false

    # Check if the gameid.ini file exists
    if [[ -f "$gameid_ini" ]]; then
        echo "Checking existing $gameid.ini file for [Controls] section..."
        
        # Read the file line by line
        while IFS= read -r line; do
            # Check if the [Controls] section exists
            if [[ "$line" == "[Controls]" ]]; then
                controls_section_exists=true
            fi
            
            # Check if PadProfile1 exists in the [Controls] section
            if [[ "$controls_section_exists" == true && "$line" == "PadProfile1 ="* ]]; then
                padprofile_exists=true
                break
            fi
        done < "$gameid_ini"
    fi

    # If the [Controls] section exists and PadProfile1 exists, update it
    if [[ "$controls_section_exists" == true && "$padprofile_exists" == true ]]; then
        echo "Updating PadProfile1 in the [Controls] section..."
        sed -i "/\[Controls\]/,/^$/s/PadProfile1 =.*/PadProfile1 = $js_profile_name/" "$gameid_ini"
    elif [[ "$controls_section_exists" == true && "$padprofile_exists" == false ]]; then
        # If the [Controls] section exists but PadProfile1 doesn't, add PadProfile1
        echo "Adding PadProfile1 to the [Controls] section..."
        sed -i "/\[Controls\]/a PadProfile1 = $js_profile_name" "$gameid_ini"
    else
        # If the [Controls] section does not exist, add it at the end of the file
        echo "Adding [Controls] section and PadProfile1..."
        echo -e "\n[Controls]" >> "$gameid_ini"
        echo "PadProfile1 = $js_profile_name" >> "$gameid_ini"
    fi

    echo "Updated $gameid_ini with PadProfile1 = $js_profile_name"
}

#  ----------------- Main script execution starts here

# Check for connected controllers and create necessary .ini files
find_game_controllers

# Handle ROM file and update GAMEID.ini (pass the ROM file as an argument to the script)
if [[ -n "$1" ]]; then
    handle_rom_and_gameid_ini "$1"
else
    echo "No ROM file provided. Please provide a ROM file as an argument."
fi

/opt/retropie/emulators/dolphin/bin/dolphin-emu -b -e "$1"
