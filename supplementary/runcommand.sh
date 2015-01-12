#!/bin/bash

# parameters - reqmode command_to_launch savename

# reqmode==0: run command
# reqmode==1: set video mode to 640x480 (4:3) or 720x480 (16:9) @60hz, and run command
# reqmode==4: set video mode to 1024x768 (4:3) or 1280x720 (16:9) @60hz, and run command

# reqmode=="CEA-#": set video mode to CEA mode #
# reqmode=="DMT-#": set video mode to DMT mode #
# reqmode=="PAL/NTSC-RATIO": set mode to SD output with RATIO of 4:3 / 16:10 or 16:9

# note that mode switching only happens if the monitor reports the modes as available (via tvservice)
# and the requested mode differs from the currently active mode

# if savename is included, that is used for loading and saving of video output modes as well as dispmanx settings
# for the current command. If omitted, the binary name is used as a key for the loading and saving. The savename is
# also displayed in the video output menu (detailed below), so for our purposes we send the emulator module id, which
# is somewhat descriptive yet short.

# on launch this script waits for 1 second for a keypress. If x or m is pressed, a menu is displayed allowing
# the user to set a screenmode for this particular command. the savename parameter is displayed to the user - we use the module id
# of the emulator we are launching.

video_conf="/opt/retropie/configs/all/videomodes.cfg"
dispmanx_conf="/opt/retropie/configs/all/dispmanx.cfg"
retronetplay_conf="/opt/retropie/configs/all/retronetplay.cfg"

declare -A mode
mode[1-4:3]="CEA-1"
mode[1-16:9]="CEA-1"
mode[4-16:9]="CEA-4"
mode[4-4:3]="DMT-16"

function get_mode() {
    local emusave="$1"
    local romsave="$2"

    # get current mode / aspect ratio
    status=$(tvservice -s)
    if [[ "$status" =~ (PAL|NTSC) ]]; then
        currentmode=$(echo "$status" | grep -oE "(PAL|NTSC) (4:3|16:10|16:9)")
    else
        currentmode=$(echo "$status" | grep -oE "(CEA|DMT) \([0-9]+\)")
        currentmode=${currentmode//[()]/}
    fi
    currentmode=${currentmode/ /-}
    aspect=$(echo "$status" | grep -oE "(16:9|4:3)")

    if [[ -f "$video_conf" ]]; then
      source "$video_conf"
      newmode="${!romsave}"
      [[ -z "$newmode" ]] && newmode="${!emusave}"
    fi

    if [[ -z "$newmode" ]]; then
        # if called with specific mode, use that else choose the best mode from our array
        if [[ "$reqmode" =~ ^(DMT|CEA)-[0-9]+$ ]]; then
            newmode="$reqmode"
        elif [[ "$reqmode" =~ ^(PAL|NTSC)-(4:3|16:10|16:9)$ ]]; then
            newmode="$reqmode"
        else
            newmode="${mode[${reqmode}-${aspect}]}"
        fi
    fi
}

function main_menu() {
    local emulator="$1"
    local emusave="$2"
    local romsave="$3"
    local default="$4"
    local save

    local cmd
    local choice

    while true; do
        local options=(
            1 "Select default video mode for emulator/port"
            2 "Select default video mode for game/rom"
            3 "Remove default video mode for game/rom"
            X "Launch")

        if [[ "$command" =~ retroarch ]]; then
            options+=(Z "Launch with netplay enabled")
        fi

        cmd=(dialog --menu "Launch configuration configuration for emulator/port $emulator"  22 76 16 )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        case $choice in
            1)
                save="$emusave"
                choose_mode
                ;;
            2)
                save="$romsave"
                choose_mode
                ;;
            3)
                sed -i "/$romsave/d" "$video_conf"
                get_mode "$emusave"
                ;;
            Z)
                netplay=1
                break
                ;;
            *|X)
                break
                ;;
        esac
    done
}

function choose_mode() {
    local group
    local line
    options=()
    for group in CEA DMT; do
        while read -r line; do
            local mode=$(echo $line | grep -oE "mode [0-9]*" | cut -d" " -f2)
            local info=$(echo $line | cut -d":" -f2-)
            info=${info/ /}
            if [[ -n "$mode" ]]; then
                options+=("$group-$mode" "$info")
            fi
        done < <(tvservice -m $group)
    done

    # add PAL / NTSC modes
    local mode
    local aspect
    for mode in "NTSC" "PAL"; do
        for aspect in "4:3" "16:10" "16:9"; do
            options+=("$mode-$aspect" "SDTV - $mode-$aspect")
        done
    done

    cmd=(dialog --default-item "$default" --menu "Choose video output mode for $emulator"  22 76 16 )
    newmode=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$newmode" ]] && return

    iniSet set "=" '"' "$save" "$newmode" "$video_conf"
}

function switch_mode() {
    local mode=(${1//-/ })
    local switched=0
    if [[ "${mode[0]}" == "PAL" ]] || [[ "${mode[0]}" == "NTSC" ]]; then
        tvservice -c "${mode[*]}"
        switched=1
    else
        hasmode=$(tvservice -m ${mode[0]} | grep -w "mode ${mode[1]}")
        if [[ -n "${mode[*]}" ]] && [[ -n "$hasmode" ]]; then
            tvservice -e "${mode[*]}"
            switched=1
        fi
    fi
    [[ $switched -eq 1 ]] && reset_framebuffer
    return $switched
}

function restore_mode() {
    local mode=(${1//-/ })
    if [[ "${mode[0]}" == "PAL" ]] || [[ "${mode[0]}" == "NTSC" ]]; then
        tvservice -c "${mode[*]}"
    else
        tvservice -p
    fi
}

function reset_framebuffer() {
    sleep 1
    fbset -depth 8
    fbset -depth 16
}

function config_dispmanx() {
    local name="$1"
    # if we have a dispmanx conf file and $name is in it (as a variable) and set to 1,
    # change the library path to load dispmanx sdl first
    if [[ -f "$dispmanx_conf" ]]; then
      source "$dispmanx_conf"
      [[ "${!name}" == "1" ]] && command="LD_LIBRARY_PATH=/opt/retropie/supplementary/sdl1dispmanx/lib $command"
    fi
}

function retroarch_append_config() {
    [[ ! "$command" =~ "retroarch" ]] && return
    local rate=$(tvservice -s | grep -oE "[0-9\.]+Hz" | cut -d"." -f1)
    echo "video_refresh_rate = $rate" >/tmp/retroarch-rate.cfg
    if [[ $netplay -eq 1 ]] && [[ -f "$retronetplay_conf" ]]; then
        source "$retronetplay_conf"
        retronetplay=" -$__netplaymode $__netplayhostip_cfile --port $__netplayport --frames $__netplayframes"
    else
        retronetplay=""
    fi
    command=$(echo "$command" | sed "s|\(--appendconfig *[^ $]*\)|\1,/tmp/retroarch-rate.cfg$retronetplay|")
}

# arg 1: set/unset, arg 2: delimiter, arg 3: quote character, arg 4: key, arg 5: value, arg 6: file
function iniSet() {
    local command="$1"
    local delim="$2"
    local quote="$3"
    local key="$4"
    local value="$5"
    local file="$6"

    local delim_strip=${delim// /}
    local match_re="[\s#]*$key\s*$delim_strip.*$"

    local match
    if [[ -f "$file" ]]; then
        match=$(egrep -i "$match_re" "$file" | tail -1)
    else
        touch "$file"
    fi

    [[ "$command" == "unset" ]] && key="# $key"
    local replace="$key$delim$quote$value$quote"
    if [[ -z "$match" ]]; then
        # add key-value pair
        echo "$replace" >> "$file"
    else
        # replace existing key-value pair
        sed -i -e "s|$match|$replace|g" "$file"
    fi
}

reqmode="$1"
[[ -z "$reqmode" ]] && exit 1

command="$2"
[[ -z "$command" ]] && exit 1

emulator="$3"
# if we have an emulator name (such as module_id) we use that for storing/loading parameters for video output/dispmanx
# if the parameter is empty we use the name of the binary (to avoid breakage with out of date emulationstation configs)
[[ -z "$emulator" ]] && emulator="${command/% */}"

# convert emulator name / binary to a names usable as variables in our config file
emusave=${emulator//\//_}
emusave=${emusave//[^a-Z0-9_]/}
romsave=r$(echo "$command" | md5sum | cut -d" " -f1)

netplay=0

get_mode "$emusave" "$romsave"

# check for x/m key pressed to choose a screenmode (x included as it is useful on the picade)
clear
echo "Press 'x' or 'm' to configure launch options for emulator/port ($emulator)"
read -t 1 -N 1 key </dev/tty
if [[ "$key" =~ [xXmM] ]]; then
    main_menu "$emulator" "$emusave" "$romsave" "$newmode"
    clear
fi

switched=0
if [[ -n "$newmode" ]] && [[ "$newmode" != "$currentmode" ]]; then
    switch_mode "$newmode"
    switched=$?
fi

config_dispmanx "$emusave"

# switch to performance cpu governor
echo "performance" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >/dev/null

retroarch_append_config

# run command
eval $command

# switch to ondemand cpu governor
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >/dev/null

# if we switched mode - restore preferred mode, and reset framebuffer
if [[ $switched -eq 1 ]]; then
    restore_mode "$currentmode"
    reset_framebuffer
fi

exit 0
