#!/bin/bash

# reqmode==0: run command
# reqmode==1: set video mode to 640x480 (4:3) or 720x480 (16:9) @60hz, and run command
# reqmode==4: set video mode to 1024x768 (4:3) or 1280x720 (16:9) @60hz, and run command

# reqmode=="CEA-#": set video mode to CEA mode #
# reqmode=="DMT-#": set video mode to DMT mode #
# reqmode=="PAL/NTSC-RATIO": set mode to SD output with RATIO of 4:3 / 16:10 or 16:9

# note that mode switching only happens if the monitor reports the modes as available (via tvservice)
# and the requested mode differs from the currently active mode

video_conf="/opt/retropie/configs/all/videomodes.cfg"
dispmanx_conf="/opt/retropie/configs/all/dispmanx"

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
    currentmode=$(echo "$status" | grep -oE "(CEA|DMT) \([0-9]+\)")
    currentmode=${currentmode/\(/}
    currentmode=${currentmode/\)/}
    currentmode=${currentmode/ /-}
    aspect=$(echo "$status" | grep -oE "(16:9|4:3)")

    if [ -f "$video_conf" ]; then
      source "$video_conf"
      newmode="${!romsave}"
      [ "$newmode" == "" ] && newmode="${!emusave}"
    fi

    if [ "$newmode" = "" ]; then
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

function choose_mode() {
    local emusave="$1"
    local romsave="$2"
    local default="$3"
    local save

    local options=()
    local cmd
    local choice
    options=(
        1 "Select default video mode for emulator"
        2 "Select default video mode for rom"
        3 "Remove default video mode for rom"
    )
    cmd=(dialog --menu "Choose which video mode option to set"  22 76 16 )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [ "$choice" == "1" ]; then
        save="$emusave"
    elif [ "$choice" == "2" ]; then
        save="$romsave"
    elif [ "$choice" == "3" ]; then
        sed -i "/$romsave/d" "$video_conf"
        get_mode "$emusave"
        return
    else
        return
    fi

    local group
    local line
    options=()
    for group in CEA DMT; do
        while read -r line; do
            local mode=$(echo $line | grep -oE "mode [0-9]*" | cut -d" " -f2)
            local info=$(echo $line | cut -d":" -f2-)
            info=${info/ /}
            if [ "$mode" != "" ]; then
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

    cmd=(dialog --default-item "$default" --menu "Choose video output mode for $binary"  22 76 16 )
    newmode=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [ "$newmode" = "" ] && return

    iniSet set "=" '"' "$save" "$newmode" "$video_conf"
}

function switch_mode() {
    local mode=(${1//-/ })
    local switched=0
    if [ "${mode[0]}" = "PAL" ] || [ "${mode[0]}" = "NTSC" ]; then
        tvservice -c "${mode[*]}"
        switched=1
    else
        hasmode=$(tvservice -m ${mode[0]} | grep -w "mode ${mode[1]}")
        if [ "${mode[*]}" != "" ] && [ "$hasmode" != "" ]; then
            tvservice -e "${mode[*]}"
            switched=1
        fi
    fi
    [ $switched -eq 1 ] && reset_framebuffer
    return $switched
}

function reset_framebuffer() {
  sleep 1
  fbset -depth 8
  fbset -depth 16
}

function config_dispmanx() {
    local binary="$1"
    # if we have a dispmanx conf file and the current binary is in it (as a variable) and set to 1,
    # change the library path to load dispmanx sdl first
    binary="`basename ${command/% */}`"
    if [ -f "$dispmanx_conf" ]; then
      source "$dispmanx_conf"
      [ "${!binary}" = "1" ] && command="LD_LIBRARY_PATH=/opt/retropie/supplementary/sdl1dispmanx/lib $@"
    fi
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
    if [ -f "$file" ]; then
        match=$(egrep -i "$match_re" "$file" | tail -1)
    else
        touch "$file"
    fi

    [ "$command" == "unset" ] && key="# $key"
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
shift

command="$@"
[[ -z "$command" ]] && exit 1

binary="${command/% */}"

# convert binary / path to a names usable as variables in our config file
emusave=${binary//\//_}
emusave=${emusave//[^a-Z0-9_]/}
romsave=r$(echo "$command" | md5sum | cut -d" " -f1)

get_mode "$emusave" "$romsave"

# check for x/m key pressed to choose a screenmode (x included as it is useful on the picade)
#clear
read -t 1 -N 1 key </dev/tty
if [[ "$key" =~ [xXmM] ]]; then
    choose_mode "$emusave" "$romsave" "$newmode"
    clear
fi

switched=0
if [ "$newmode" != "" ] && [ "$newmode" != "$currentmode" ]; then
    switch_mode "$newmode"
    switched=$?
fi

config_dispmanx "$binary"

# switch to performance cpu governor
echo "performance" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >/dev/null

# run command
eval $command

# switch to ondemand cpu governor
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >/dev/null

# if we switched mode - restore preferred mode, and reset framebuffer
if [ $switched -eq 1 ]; then
    tvservice -p
    reset_framebuffer
fi

exit 0
