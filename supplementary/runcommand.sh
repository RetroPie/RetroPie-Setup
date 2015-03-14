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

configdir="/opt/retropie/configs"
runcommand_conf="$configdir/all/runcommand.cfg"
video_conf="$configdir/all/videomodes.cfg"
apps_conf="$configdir/all/emulators.cfg"
dispmanx_conf="$configdir/all/dispmanx.cfg"
retronetplay_conf="$configdir/all/retronetplay.cfg"

declare -A mode_map
declare -A mode

mode_map[1-CEA-4:3]="CEA-1"
mode_map[1-DMT-4:3]="DMT-4"
mode_map[1-CEA-16:9]="CEA-1"

mode_map[4-CEA-4:3]="DMT-16"
mode_map[4-DMT-4:3]="DMT-16"
mode_map[4-CEA-16:9]="CEA-4"

function get_params() {
    reqmode="$1"
    [[ -z "$reqmode" ]] && exit 1

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

function get_save_vars() {
    # convert emulator name / binary to a names usable as variables in our config file
    emusave=${emulator//\//_}
    emusave=${emusave//[^a-Z0-9_]/}
    rendersave="${emusave}_render"
    romsave=r$(echo "$command" | md5sum | cut -d" " -f1)
}

function get_all_modes() {
    local group
    for group in CEA DMT; do
        while read -r line; do
            local id=$(echo $line | grep -oE "mode [0-9]*" | cut -d" " -f2)
            local info=$(echo $line | cut -d":" -f2-)
            info=${info/ /}
            if [[ -n "$id" ]]; then
                mode_id+=($group-$id)
                mode[$group-$id]="$info"
            fi
        done < <(tvservice -m $group)
    done
    local aspect
    for group in "NTSC" "PAL"; do
        for aspect in "4:3" "16:10" "16:9"; do
            mode_id+=($group-$aspect)
            mode[$group-$aspect]="SDTV - $group-$aspect"
        done
    done
}

function get_mode() {
    # get current mode / aspect ratio
    mode_cur_status=$(tvservice -s)
    if [[ "$mode_cur_status" =~ (PAL|NTSC) ]]; then
        mode_cur=$(echo "$mode_cur_status" | grep -oE "(PAL|NTSC) (4:3|16:10|16:9)")
        mode_cur=${mode_cur/ /-}
    else
        mode_cur=($(echo "$mode_cur_status" | grep -oE "(CEA|DMT) \([0-9]+\)"))
        mode_cur_type="${mode_cur[0]}"
        mode_cur_id="${mode_cur[1]//[()]/}"
        mode_cur="$mode_cur_type-$mode_cur_id"
    fi

    mode_cur_aspect=$(echo "$mode_cur_status" | grep -oE "(16:9|4:3)")
    # if current aspect is anything else like 5:4 / 10:9 just choose a 4:3 mode
    [[ -z "$mode_cur_aspect" ]] && mode_cur_aspect="4:3"

    mode_new="$mode_cur"

    # if called with specific mode, use that else choose the best mode from our array
    if [[ "$reqmode" =~ ^(DMT|CEA)-[0-9]+$ ]]; then
        mode_new="$reqmode"
    elif [[ "$reqmode" =~ ^(PAL|NTSC)-(4:3|16:10|16:9)$ ]]; then
        mode_new="$reqmode"
    else
        local map_mode="${mode_map[${reqmode}-${mode_cur_type}-${mode_cur_aspect}]}"
        [[ -n "$map_mode" ]] && mode_new="$map_mode"
    fi

    mode_def_emu=""
    mode_def_rom=""
    render_res="640x480"

    if [[ -f "$video_conf" ]]; then
        iniGet "$emusave" "$video_conf"
        if [[ -n "$ini_value" ]]; then
            mode_def_emu="$ini_value"
            mode_new="$mode_def_emu"
        fi

        iniGet "$romsave" "$video_conf"
        if [[ -n "$ini_value" ]]; then
            mode_def_rom="$ini_value"
            mode_new="$mode_def_rom"
        fi

        iniGet "$rendersave" "$video_conf"
        if [[ -n "$ini_value" ]]; then
            render_res="$ini_value"
        fi
    fi
}

function main_menu() {
    local save
    local cmd
    local choice

    [[ -z "$rom_bn" ]] && rom_bn="game/rom"
    [[ -z "$system" ]] && system="emulator/port"

    while true; do

        local options=()
        if [[ $is_sys -eq 1 ]]; then
            options+=(
                1 "Select default emulator for $system ($emulator_def_sys)"
                2 "Select emulator for rom ($emulator_def_rom)"
            )
            [[ -n "$emulator_def_rom" ]] && options+=(3 "Remove emulator choice for rom")
        fi

        if [[ $has_tvs -eq 1 ]]; then
            options+=(
                4 "Select default video mode for $emulator ($mode_def_emu)"
                5 "Select video mode for $emulator + rom ($mode_def_rom)"
            )
            [[ -n "$mode_def_emu" ]] && options+=(6 "Remove video mode choice for $emulator")
            [[ -n "$mode_def_rom" ]] && options+=(7 "Remove video mode choice for $emulator + rom")
        fi

        [[ "$command" =~ retroarch ]] && options+=(8 "Select RetroArch render res for $emulator ($render_res)")

        options+=(X "Launch")

        if [[ "$command" =~ retroarch ]]; then
            options+=(Z "Launch with netplay enabled")
        fi

        cmd=(dialog --menu "System: $system\nEmulator: $emulator\nVideo Mode: ${mode[$mode_new]}\nROM: $rom_bn"  22 76 16 )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        case $choice in
            1)
                choose_app
                get_save_vars
                get_mode
                ;;
            2)
                choose_app "$appsave"
                get_save_vars
                get_mode
                ;;
            3)
                sed -i "/$appsave/d" "$apps_conf"
                get_sys_command "$system" "$rom"
                ;;
            4)
                choose_mode "$emusave" "$mode_def_emu"
                get_mode
                ;;
            5)
                choose_mode "$romsave" "$mode_def_rom"
                get_mode
                ;;
            6)
                sed -i "/$emusave/d" "$video_conf"
                get_mode
                ;;
            7)
                sed -i "/$romsave/d" "$video_conf"
                get_mode
                ;;
            8)
                choose_render_res "$rendersave"
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
    local save="$1"
    local default="$2"
    options=()
    local key
    for key in ${mode_id[@]}; do
        options+=("$key" "${mode[$key]}")
    done
    local cmd=(dialog --default-item "$default" --menu "Choose video output mode"  22 76 16 )
    mode_new=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$mode_new" ]] && return

    iniSet set "=" '"' "$save" "$mode_new" "$video_conf"
}

function choose_app() {
    local save="$1"
    local default
    local default_id
    if [[ -n "$save" ]]; then
        default="$emulator"
    else
        default="$emulator_def_sys"
    fi
    local options=()
    local i=1
    while read line; do
        # convert key=value to array
        local line=(${line/=/ })
        local id=${line[0]}
        [[ "$id" == "default" ]] && continue
        local apps[$i]="$id"
        if [[ "$id" == "$default" ]]; then
            default_id="$i"
        fi
        options+=($i "$id")
        ((i++))
    done <"$configdir/$system/emulators.cfg"
    if [[ -z "${options[*]}" ]]; then
        dialog --msgbox "No emulator options found for $system - have you installed any snes emulators yet? Do you have a valid $configdir/$system/emulators.cfg ?" 20 60 >/dev/tty
        exit 1
    fi
    local cmd=(dialog --default-item "$default_id" --menu "Choose default emulator"  22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        if [[ -n "$save" ]]; then
            iniSet set "=" '"' "$save" "${apps[$choice]}" "$apps_conf"
        else
            iniSet set "=" '"' "default" "${apps[$choice]}" "$configdir/$system/emulators.cfg"
        fi
        get_sys_command "$system" "$rom"
    fi
}

function choose_render_res() {
    local save="$1"
    local res=(
        "320x240"
        "640x480"
        "960x720"
        "1280x960"
        "Use video output resolution"
        "Use config file resolution"
    )
    local i=1
    local item
    local options=()
    for item in "${res[@]}"; do
        options+=($i "$item")
        ((i++))
    done
    local cmd=(dialog --menu "Choose RetroArch render resolution" 22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return
    case "$choice" in
        [1-4])
            render_res="${res[$choice-1]}"
            ;;
        5)
            render_res="output"
            ;;
        6)
            render_res="config"
            ;;
    esac

    iniSet set "=" '"' "$save" "$render_res" "$video_conf"
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
        iniGet "$name" "$dispmanx_conf"
        [[ "$ini_value" == "1" ]] && command="SDL1_VIDEODRIVER=dispmanx $command"
    fi
}

function retroarch_append_config() {
    # only for retroarch emulators
    [[ ! "$command" =~ "retroarch" ]] && return

    local conf="/tmp/retroarch.cfg"
    rm -f "$conf"
    touch "$conf"
    if [[ "$has_tvs" -eq 1 ]]; then
        # set video_refresh_rate in our config to the same as the screen refresh
        local rate=$(tvservice -s | grep -oE "[0-9\.]+Hz" | cut -d"." -f1)
        [[ -n "$rate" ]] && echo "video_refresh_rate = $rate" >>"$conf"
    fi

    local dim
    # if we don't have a saved render resolution use 640x480

    # if our render resolution is "config", then we don't set anything (use the value in the retroarch.cfg)
    if [[ "$render_res" != "config" ]]; then
        if [[ "$render_res" == "output" ]]; then
            dim=(0 0)
        else
            dim=(${render_res/x/ })
        fi
        echo "video_fullscreen_x = ${dim[0]}" >>"$conf"
        echo "video_fullscreen_y = ${dim[1]}" >>"$conf"
    fi

    if [[ "$command" =~ "--appendconfig" ]]; then
        command=$(echo "$command" | sed "s|\(--appendconfig *[^ $]*\)|\1,$conf|")
    else
        command+=" --appendconfig $conf"
    fi
    if [[ $netplay -eq 1 ]] && [[ -f "$retronetplay_conf" ]]; then
        source "$retronetplay_conf"
        command+=" -$__netplaymode $__netplayhostip_cfile --port $__netplayport --frames $__netplayframes"
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

# arg 1: key, arg 2: file - value ends up in ini_value variable
function iniGet() {
    local key="$1"
    local file="$2"
    ini_value=$(sed -rn "s|^[\s]*$key\s*=\s*\"(.+)\".*|\1|p" $file)
}

function set_governor() {
    governor_old=()
    for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
        governor_old+=($(<$cpu))
        echo "$1" | sudo tee "$cpu" >/dev/null
    done
}

function restore_governor() {
    local i=0
    for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
        echo "${governor_old[$i]}" | sudo tee "$cpu" >/dev/null
        ((i++))
    done
}

function get_sys_command() {
    system="$1"
    rom="$2"
    rom_bn="${rom##*/}"
    rom_bn="${rom_bn%.*}"
    appsave=a$(echo "$system$rom" | md5sum | cut -d" " -f1)
    local emu_conf="$configdir/$system/emulators.cfg"

    if [[ ! -f "$emu_conf" ]]; then
        echo "No config found for system $system"
        exit 1
    fi

    iniGet "default" "$emu_conf"
    if [[ -z "$ini_value" ]]; then
        echo "No default emulator found for system $system"
        choose_app
        get_sys_command "$1" "$2"
        return
    fi

    emulator="$ini_value"
    emulator_def_sys="$emulator"

    # get system & rom specific app if set
    if [[ -f "$apps_conf" ]]; then
        iniGet "$appsave" "$apps_conf"
        emulator_def_rom="$ini_value"
        [[ -n "$ini_value" ]] && emulator="$ini_value"
    fi

    # get the app commandline
    iniGet "$emulator" "$emu_conf"
    command="$ini_value"

    # replace tokens
    command="${command/\%ROM\%/\"$rom\"}"
    command="${command/\%BASENAME\%/\"$rom_bn\"}"
}

if [[ -f "$runcommand_conf" ]]; then
    iniGet "governor" "$runcommand_conf"
    governor="$ini_value"
fi

if [[ -n "$(which tvservice)" ]]; then
    has_tvs=1
else
    has_tvs=0
fi

get_params "$@"

get_save_vars

[[ $has_tvs -eq 1 ]] && get_mode

# check for x/m key pressed to choose a screenmode (x included as it is useful on the picade)
clear
echo "Press 'x' or 'm' to configure launch options for emulator/port ($emulator)"
read -t 1 -N 1 key </dev/tty
if [[ "$key" =~ [xXmM] ]]; then
    get_all_modes
    main_menu
    clear
fi

switched=0
if [[ -n "$mode_new" ]] && [[ "$mode_new" != "$mode_cur" ]]; then
    switch_mode "$mode_new"
    switched=$?
fi

config_dispmanx "$emusave"

# switch to configured cpu scaling governor
[[ -n "$governor" ]] && set_governor "$governor"

retroarch_append_config

# run command
eval $command

# restore default cpu scaling governor
[[ -n "$governor" ]] && restore_governor

# if we switched mode - restore preferred mode, and reset framebuffer
if [[ $switched -eq 1 ]]; then
    restore_mode "$mode_cur"
fi

reset_framebuffer

exit 0
