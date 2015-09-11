#!/bin/bash

# parameters - mode_req command_to_launch savename

# mode_req==0: run command
# mode_req==1: set video mode to 640x480 (4:3) or 720x480 (16:9) @60hz, and run command
# mode_req==4: set video mode to 1024x768 (4:3) or 1280x720 (16:9) @60hz, and run command

# mode_req=="CEA-#": set video mode to CEA mode #
# mode_req=="DMT-#": set video mode to DMT mode #
# mode_req=="PAL/NTSC-RATIO": set mode to SD output with RATIO of 4:3 / 16:10 or 16:9

# note that mode switching only happens if the monitor reports the modes as available (via tvservice)
# and the requested mode differs from the currently active mode

# if savename is included, that is used for loading and saving of video output modes as well as dispmanx settings
# for the current command. If omitted, the binary name is used as a key for the loading and saving. The savename is
# also displayed in the video output menu (detailed below), so for our purposes we send the emulator module id, which
# is somewhat descriptive yet short.

# on launch this script waits for 1 second for a keypress. If x or m is pressed, a menu is displayed allowing
# the user to set a screenmode for this particular command. the savename parameter is displayed to the user - we use the module id
# of the emulator we are launching.

realpath () {
	if cd $1; then pwd; else return 1; fi
}
runcommandhome="$(realpath "$(dirname "$(readlink "$0")")")"

. "$runcommandhome/lib/include"

function get_params() {
    mode_req="$1"
    [[ -z "$mode_req" ]] && exit 1

    command="$2"
    [[ -z "$command" ]] && exit 1

    # if the command is _SYS_, arg 3 should be system name, and arg 4 rom/game, and we look up the configured system for that combination
    if [[ "$command" == "_SYS_" ]]; then
        is_sys=1
        get_sys_command "$3" "$4"
    else
        is_sys=0
        emulator="$3"
        # if we have an emulator name (such as module_id) we use that for storing/loading parameters for video output/dispmanx
        # if the parameter is empty we use the name of the binary (to avoid breakage with out of date emulationstation configs)
        [[ -z "$emulator" ]] && emulator="${command/% */}"
    fi

    netplay=0
}



get_params "$@"

get_save_vars

load_mode_defaults

dont_launch=0

# check for x/m key pressed to choose a screenmode (x included as it is useful on the picade)
clear
echo "Press a key (or joypad button 0) to configure launch options for emulator/port ($emulator). Errors will be logged to /tmp/runcommand.log"
IFS= read -s -t 1 -N 1 key </dev/tty
if [[ -n "$key" ]]; then
    get_all_modes
    main_menu
    dont_launch=$?
    clear
fi

if [[ -n $__joy2key_pid ]]; then
    kill -INT $__joy2key_pid
fi

if [[ $dont_launch -eq 1 ]]; then
    exit 0
fi

switch_mode "$mode_new_id"
switched=$?

[[ -n "$fb_new" ]] && switch_fb_res "$fb_new"

config_dispmanx "$save_emu"

# switch to configured cpu scaling governor
[[ -n "$governor" ]] && set_governor "$governor"

retroarch_append_config

# run command
eval $command </dev/tty 2>/tmp/runcommand.log

# restore default cpu scaling governor
[[ -n "$governor" ]] && restore_governor

# if we switched mode - restore preferred mode
if [[ $switched -eq 1 ]]; then
    restore_mode "$mode_cur"
fi

# reset/restore framebuffer res
restore_fb

exit 0
