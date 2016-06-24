#!/usr/bin/env bash
# joystickselect.sh
############################ official disclaimer #############################
# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
##############################################################################
# Show the available joysticks and let the user choose what controller to
# use for RetroArch Player 1-4.
#
# This program relies on the output of the jslist program to get the
# available joysticks and their respective indexes.
#
# Short description of what this script does:
# - puts at the beginning of $configdir/all/retroarch.cfg an "#include" 
#   pointing to the file $configdir/all/input-selection.cfg
# - let the user manage the input-selection.cfg through dialogs (this file
#   contains the configs for input_playerN_joypad_index for players 1-4).
#
# OBS.: the joystick selection doesn't work if the config_save_on_exit is set to true,
#       because the retroarch.cfg is overwritten frequently.
#
# TODO:
#      - implement the same functionality for non-libretro emulators.
#      - [robustness] alert the user if the Player 1 has no joystick.
#      - [robustness] verify if the "#include ...input-selection.cfg" line
#        is before any input_playerN_joypad_index in the retroarch.cfg.
#
# meleu, 2016/06


rp_module_id="joystickselect"
rp_module_desc="Show the available joysticks and let you choose which to use for RetroArch Players 1-4."
rp_module_section="config"

jslist_exe="$rootdir/supplementary/jslist"
js_list_file="/tmp/jslist-$$"
retroarchcfg="$configdir/all/retroarch.cfg"
inputcfg="$configdir/all/input-selection.cfg"


function depends_joystickselect() {
    # libsdl2-dev package is needed for jslist.c compilation
    getDepends libsdl2-dev

    [[ -x "$jslist_exe" ]] || {
        wget -O /tmp/jslist.c \
          https://raw.githubusercontent.com/meleu/RetroPie-input-selection/master/jslist.c

        gcc /tmp/jslist.c -o "$jslist_exe" $(sdl2-config --cflags --libs) ||
          fatalError "Unable to compile jslist.c!"
    }
}



###############################################################################
# Puts the default joystick input configuration content in the given
# file ($1 argument).
# The default is:
# input_player1_joypad_index = "0"
# input_player2_joypad_index = "1"
# input_player3_joypad_index = "2"
# input_player4_joypad_index = "3"
#
# Globals:
#   None
#
# Arguments:
#   $1 : NEEDED. The file where the default config will be put.
#
# Returns:
#   1: if fails.
function default_input_config() {
    [[ "$1" ]] || fatalError "default_input_config: missing argument!"

    local temp_inputcfg
    temp_inputcfg="$1"

    cat << _EOF_ > "$temp_inputcfg"
# This file is used to choose which controller to use for each player.
input_player1_joypad_index = "0"
input_player2_joypad_index = "1"
input_player3_joypad_index = "2"
input_player4_joypad_index = "3"
_EOF_
    if [ "$?" -ne 0 ]; then
        printMsgs "dialog" "Unable to create a default configuration"
        return 1
    fi

    chown $user.$user "$temp_inputcfg"
}



###############################################################################
# Fills the js_list_file with the available joysticks and their indexes.
#
# Globals:
#   jslist_exe
#   js_list_file
#
# Arguments:
#   None
#
# Returns:
#   1: if no joystick found.
function fill_js_list_file() {
    local temp_file
    temp_file=$(mktemp deleteme.XXXX)

    # the jslist returns a non-zero value if it doesn't find any joystick
    $jslist_exe > $temp_file || {
        printMsgs "dialog" "No joystick found. :("
        rm -f "$temp_file"
        return 1
    }

    # This obscure command searches for duplicated joystick names and puts
    # a sequential number at the end of the repeated ones
    # credit goes to fedorqui (http://stackoverflow.com/users/1983854/fedorqui)
    awk -F: 'FNR==NR {count[$2]++; next}
             count[$2]>1 {$0=$0 OFS "#"++times[$2]}
             1' $temp_file $temp_file > $js_list_file

    # No need for this file anymore
    rm -f "$temp_file"
}



###############################################################################
# Checking the following:
#   - if retroarch.cfg has the "#include" line for input-selection.cfg, in
#     failure case let the user decide if we can add it to the file.
#   - if input-selection.cfg exists, create it if doesn't.
#   - if jslist exists and is executable
#
# Globals:
#   retroarchcfg
#   inputcfg
#   jslist_exe
#
# Arguments:
#   None
#
# Returns:
#   1: if fails
function check_files() {
    # checking if the "#include ..." line is in the retroarch.cfg
    grep -q "^#include \"$inputcfg\"$" "$retroarchcfg" || {
        dialog \
          --backtitle "$__backtitle" \
          --title "Error" \
          --yesno \
"Your retroarch.cfg isn't properly configured to work with this method of
joystick selection. You need to put the following line on your \"$retroarchcfg\"
(preferably at the beginning):
\n\n#include \"$inputcfg\"\n\n
Do you want me to put it at the beginning of the retroarch.cfg now?
\n(if you choose \"No\", I will stop now)" \
          0 0 >/dev/tty || {
            return 1;
        }

          # Putting the "#include ..." at the beginning line of retroarch.cfg
          sed -i "1i\
# $(date +%Y-%m-%d): The following line was added to allow joystick selection\n\
#include \"$inputcfg\"\n" \
            "$retroarchcfg" || return 1
    } # end of failed grep

    # if the input-selection.cfg doesn't exist or is empty, create it with
    # default values
    [[ -s "$inputcfg" ]] || default_input_config "$inputcfg"

    # checking if jslist exists and is executable
    [[ -x "$jslist_exe" ]] || {
        printMsgs "dialog" "\"$jslist_exe\" not found or isn't executable!" 
        return 1
    } # end of failed jslist_exe

} # end of check_files



###############################################################################
# Show the input config with the joystick names, and let the user decide if
# he/she wants to continue.
# The caller of this function must deal with the user decision. It returns
# 1 if the user choose "No", and 0 if the user choose "Yes".
#
# Globals:
#   js_list_file
#
# Arguments:
#   $1 : NEEDED. The input-selection.cfg file. It's just a
#        retroarch.cfg like file with the input_playerN_joypad_index variables.
#   $2 : OPTIONAL. Its a string with a question to ask in the yesno dialog.
#        Keep in mind that the "No" answer always exit.
#
# Returns:
#   -1: if it fails
#    1: if the user choose No in the --yesno dialog box.
#    0: if the user choose Yes in the --yesno dialog box.
function show_input_config() {
    [[ -f "$1" ]] || {
        fatalError "Error: show_input_config: invalid argument!"
        return -1
    }

    fill_js_list_file

    local cfg_file
    cfg_file="$1"

    local question
    question=${2:-"Would you like to continue?"}

    local current_config_string

    for i in $(seq 1 4); do
        # the command sequence below takes the number after the = sign,
        # deleting the "double quotes" if they exist.
        js_index_p[$i]=$(
          grep -m 1 "^input_player${i}_joypad_index" "$cfg_file" \
          | cut -d= -f2 \
          | sed 's/ *"\?\([0-9]\)*"\?.*/\1/' \
        )

        # getting the joystick names
        if [[ -z "${js_index_p[$i]}" ]]; then
            js_name_p[$i]="** NO JOYSTICK! **"
        else 
            js_name_p[$i]=$(
              grep "^${js_index_p[$i]}" "$js_list_file" \
              | cut -d: -f2
            )

            [[ -z "${js_name_p[$i]}" ]] &&
                js_name_p[$i]="** NO JOYSTICK! **"
        fi

        current_config_string="$current_config_string\n\
Player $i is set to \"${js_index_p[$i]}\" (${js_name_p[$i]})"

    done

    dialog \
      --backtitle "$__backtitle" \
      --title "Joystick selection" \
      --yesno "$current_config_string\n\n$question" \
      0 0 >/dev/tty || return 1

    return 0
} # end of show_input_config



###############################################################################
# Start a new joystick input selection configuration for players 1-4.
#
# Globals:
#   inputcfg
#   js_list_file
#
# Arguments:
#   None
#
# Returns:
#   1: if fails.
#   0: if the user don't want to change the config
function new_input_config() {
    fill_js_list_file || return 1

    local temp_file
    local temp_inputcfg
    local options
    local choice
    local old
    local new

    temp_file=$(mktemp temp.XXXX)
    temp_inputcfg=$(mktemp inputcfg.XXXX)

    cat "$inputcfg" > "$temp_inputcfg"
    for i in $(seq 1 4); do
        options="K \"Keep the current configuration for player $i\""
        # The sed below obtain the joystick list with the format
        # index "Joystick Name"
        # to use as dialog menu options
        options="$options $(sed 's/:\(.*\)/ "\1"/' $js_list_file)"
        choice=$(echo "$options" \
                    | xargs dialog \
                        --backtitle "$__backtitle" \
                        --title "Player $i joystick selection" \
                        --menu "Which controller do you want to use for Player $i?" \
                        0 0 0 2>&1 >/dev/tty
        )

        # if the user choose K or Cancel, it'll keep the current config
        if [ -n "$choice" -a "$choice" != "K" ]; then
            old="^input_player${i}_joypad_index.*"
            new="input_player${i}_joypad_index = $choice"

            sed "s/$old/$new/" "$temp_inputcfg" > "$temp_file"

            cat "$temp_file" > "$temp_inputcfg"
        fi
    done

    show_input_config "$temp_inputcfg" "Do you accept this config?" || return 1

    # If the script reaches this point, the user accepted the config
    cat "$temp_inputcfg" > "$inputcfg"

    rm -f "$temp_file" "$temp_inputcfg"
} # end of new_input_config


###############################################################################
# This is a kind of "main()" function.
#
# Globals:
#   js_list_file
#   jslist_exe
#   inputcfg
#
# Returns:
#   1: if there is some problem with the config files
function gui_joystickselect() {
    local temp_file
    local options
    local choices

    temp_file=$(mktemp input-cfg.XXXX)

    check_files || return 1

    while true; do
        cmd=(dialog --backtitle "$__backtitle"
             --menu "Joystick selection for RetroArch players 1-4." 18 80 12)
        options=(
            1 "Show current joystick selection for players 1-4."
            2 "Start a new joystick selection for players 1-4."
            3 "Restore the default settings."
        )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        if [[ -n "$choices" ]]; then
            case $choices in
                1) show_input_config "$inputcfg" \
                     "Choose Yes or No to go to the previous menu." ;;

                2) new_input_config ;;

                3) default_input_config "$temp_file"
                   show_input_config "$temp_file" \
                     "This is the default configuration. Do you accept it?" || continue
 
                   cat "$temp_file" > "$inputcfg"
                   ;;

            esac
        else
            rm -f "$js_list_file" "$temp_file"
            break
        fi
    done
} # end of gui_joystickselect
