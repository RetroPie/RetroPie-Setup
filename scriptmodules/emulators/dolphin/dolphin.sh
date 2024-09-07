#!/bin/bash

# Directory for controller profiles
profile_dir="/opt/retropie/configs/gc/Config/Profiles/GCPad"
gameid_ini_dir="/opt/retropie/configs/gc/local/GameSettings"  # Directory where GAMEID .ini files are stored
Dolphin_tool="/opt/retropie/emulators/dolphin/bin/dolphin-tool"
hotkeys_file="/opt/retropie/configs/gc/Config/Hotkeys.ini"

# Array to hold js profile names
js_profile_names=()

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
            # Extract the device name and trim any leading/trailing whitespace
            device_name=$(echo "$line" | cut -d'"' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        fi

        # Check for handlers that include jsX (joystick)
        if [[ $line == *Handlers=* ]] && [[ $line == *js[0-9]* ]]; then
            js_device=$(echo $line | grep -o 'js[0-9]')
            echo "Detected Game Controller: $device_name ($js_device)"
            
            # Create the .ini file if it doesn't exist
            check_and_create_ini "$device_name"

            # Store the profile name in an array
            js_profile_names+=("$device_name")

            # Update hotkeys for each controller found
            check_and_update_hotkeys "$device_name"
        fi
    done < /proc/bus/input/devices

    # If no joysticks were found, notify the user
    if [[ ${#js_profile_names[@]} -eq 0 ]]; then
        echo "No joystick found (js0 to js8)."
    else
        echo "Using profiles for: ${js_profile_names[@]}"
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
    local new_entry="\`evdev/0/$controller_name:SELECT\` & \`evdev/0/$controller_name:START\`"
    
    # Path to Hotkeys.ini file
    local hotkeys_file="/opt/retropie/configs/gc/Config/Hotkeys.ini"
    
    # Check if the Hotkeys file exists
    if [[ ! -f "$hotkeys_file" ]]; then
        echo "Hotkeys.ini file not found: $hotkeys_file"
        return
    fi

    # Create a backup of the file
    cp "$hotkeys_file" "$hotkeys_file.bak"

    # Use grep to check if the controller name is already in the General/Exit line
    if grep -q "^General/Exit = .*evdev/0/$controller_name" "$hotkeys_file"; then
        echo "The controller $controller_name is already in the General/Exit line. Skipping addition."
    else
        # If the General/Exit line exists, append the new entry with an OR operator
        if grep -q "^General/Exit = " "$hotkeys_file"; then
            # Escape special characters in sed and append new_entry with pipe separator
            sed -i "/^General\/Exit = /s/$/ \| $(echo "$new_entry" | sed 's/[\/&|]/\\&/g')/" "$hotkeys_file"
        else
            # If the General/Exit line does not exist, add it with backticks
            echo "General/Exit = $new_entry" >> "$hotkeys_file"
        fi

        echo "Added new entry for $controller_name to the General/Exit line."
    fi
}


# This function handles the ROM file and updates the GAMEID.ini file
function handle_rom_and_gameid_ini {
    local ROM="$1"
    local ROM_DIR="$HOME/RetroPie/roms/gc/"
    local gameid_ini_dir="/opt/retropie/configs/gc/local/GameSettings"  # Update this path as necessary

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
    local Output=$($Dolphin_tool header -i "$ROM")

    # Extract GAMEID
    local gameid=$(echo "$Output" | grep "Game ID:" | awk '{print $3}')
    
    # Path to GAMEID.ini
    gameid_ini="$gameid_ini_dir/$gameid.ini"  # Store the path in the original variable
    
    # Extract the Internal Name and Country
    local INTERNAL_NAME=$(echo "$Output" | grep "Internal Name:" | awk -F': ' '{print $2}')
    local COUNTRY=$(echo "$Output" | grep "Country:" | awk -F': ' '{print $2}')

    # If no profiles are available, skip updating the GAMEID.ini
    if [[ ${#js_profile_names[@]} -eq 0 ]]; then
        echo "No controller profiles found. Skipping GAMEID.ini update."
        return
    fi

    # Initialize flags
    local controls_section_exists=false
    local padprofile_exists=()
    local is_new_file=false

    # Initialize padprofile_exists array with false for each possible PadProfile
    for i in "${!js_profile_names[@]}"; do
        padprofile_exists[$i]=false
    done

    # Check if the gameid.ini file exists
    if [[ ! -f "$gameid_ini" ]]; then
        # If the file doesn't exist, mark it as a new file
        is_new_file=true
        touch "$gameid_ini"
    else
        echo "Checking existing $gameid_ini file for [Controls] section..."
        
        # Read the file line by line
        while IFS= read -r line; do
            # Check if the [Controls] section exists
            if [[ "$line" == "[Controls]" ]]; then
                controls_section_exists=true
            fi
            
            # Check if any PadProfile entry exists in the [Controls] section
            for i in "${!js_profile_names[@]}"; do
                local padprofile_num=$((i+1))
                if [[ "$controls_section_exists" == true && "$line" == "PadProfile${padprofile_num} ="* ]]; then
                    padprofile_exists[$i]=true
                fi
            done
        done < "$gameid_ini"
    fi

    # If it's a new file, write the game info at the top
    if [[ "$is_new_file" == true ]]; then
        echo "Game ID: $gameid (Internal Name: $INTERNAL_NAME, Country: $COUNTRY)" > "$gameid_ini"
    fi

    # Add/update PadProfile entries for each controller
    for i in "${!js_profile_names[@]}"; do
        local padprofile_num=$((i+1))
        local padprofile="PadProfile${padprofile_num} = ${js_profile_names[i]}"

        if [[ "$controls_section_exists" == true && "${padprofile_exists[$i]}" == true ]]; then
            # Update existing PadProfile entries in the gameid.ini file
            sed -i "s/^PadProfile${padprofile_num} =.*/$padprofile/" "$gameid_ini"
        else
            # Append the [Controls] section and PadProfile entries if not present
            if [[ "$controls_section_exists" == false ]]; then
                echo -e "\n[Controls]" >> "$gameid_ini"
                controls_section_exists=true
            fi

            echo "$padprofile" >> "$gameid_ini"
        fi
    done
    
    # Output after all updates are made
    echo "Updated or created $gameid.ini file with controller profiles."
}

# Define a cleanup function to remove all PadProfiles except PadProfile1 from the specific gameid.ini
cleanup() {
    if [[ -n "$gameid_ini" && -f "$gameid_ini" ]]; then
        echo "Cleaning up $gameid_ini by removing PadProfiles except PadProfile1..."

        # Use sed to remove all PadProfiles except PadProfile1
        sed -i '/^PadProfile[2-9] =/d' "$gameid_ini"
        sed -i '/^PadProfile[1-9][0-9][0-9]* =/d' "$gameid_ini"  # Remove PadProfile10 and above
        
        echo "Cleaned $gameid_ini"
    else
        echo "No gameid.ini file to clean up."
    fi
}

# Set the trap to call the cleanup function on script exit (EXIT) or interruption (INT)
trap cleanup EXIT

# Call the find_game_controllers function
find_game_controllers

# Handle ROM file and update GAMEID.ini (pass the ROM file as an argument to the script)
if [[ -n "$1" ]]; then
    handle_rom_and_gameid_ini "$1"
else
    echo "No ROM file provided. Please provide a ROM file as an argument."
fi

# Launch Dolphin Emulator in the background and wait for it to finish
/opt/retropie/emulators/dolphin/bin/dolphin-emu -b -e "$1"
