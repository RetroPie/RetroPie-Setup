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
            check_and_read_ini "$device_name"

            # Store the profile name in an array
            js_profile_names+=("$device_name")

#            # Update hotkeys for each controller found
#            update_hotkeys_file "$device_name"
        fi
    done < /proc/bus/input/devices

    # If no joysticks were found, echo into log
    if [[ ${#js_profile_names[@]} -eq 0 ]]; then
        echo "No joystick found (js0 to js8)."
    else
        echo "Using profiles for: ${js_profile_names[@]}"
    fi
}

function check_and_read_ini {
    local controller_name="$1"
    local ini_file="$profile_dir/$controller_name.ini"
    
    # Check if the .ini file exists
    if [[ ! -f "$ini_file" ]]; then
        echo "No .ini file for $controller_name exists..."
        
    else
        echo ".ini file for $controller_name already exists."

        # Read Hotkey and Buttons/Start values from the .ini file
        local hotkey_button
        local start_button

        # Extract Hotkey and Start buttons using grep and awk
        hotkey_button=$(grep -E "^Hotkey" "$ini_file" | awk -F' = ' '{print $2}')
        start_button=$(grep -E "^Buttons/Start" "$ini_file" | awk -F' = ' '{print $2}')

        # Remove backticks if they exist
        hotkey_button=$(echo "$hotkey_button" | sed 's/`//g')
        start_button=$(echo "$start_button" | sed 's/`//g')

        # Trim leading and trailing spaces
        hotkey_button=$(echo "$hotkey_button" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        start_button=$(echo "$start_button" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        

        # Use the variables to update Hotkeys.ini
        update_hotkeys_file "$controller_name" "$hotkey_button" "$start_button"
    fi
}

function update_hotkeys_file {
    local controller_name="$1"
    local hotkey_button="$2"
    local start_button="$3"

    # Create a .bak backup of the hotkeys file if it exists
    if [[ -f "$hotkeys_file" ]]; then
        cp "$hotkeys_file" "${hotkeys_file}.bak"
        echo "Backup created: ${hotkeys_file}.bak"
    else
        # Create the file if it doesn't exist
        touch "$hotkeys_file"
        echo "Hotkeys file created: $hotkeys_file"
    fi

    # Prepare the replacement line
    local new_exit_line="\`evdev/0/$controller_name:$hotkey_button\` & \`evdev/0/$controller_name:$start_button\`"

    # Check if the General/Exit = line exists, and replace it
    if grep -q "^General/Exit =" "$hotkeys_file"; then
        # Remove the original line and replace it with the new line
        sed -i "/^General\/Exit =/c General/Exit = $new_exit_line" "$hotkeys_file"
        echo "Replaced General/Exit line with: General/Exit = $new_exit_line"
    else
        # If General/Exit line doesn't exist, append it
        echo "General/Exit = $new_exit_line" >> "$hotkeys_file"
        echo "Added new General/Exit line: General/Exit = $new_exit_line"
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
