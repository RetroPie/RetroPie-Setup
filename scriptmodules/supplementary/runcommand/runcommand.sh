#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# parameters - MODE_REQ COMMAND savename

# MODE_REQ==0: run COMMAND
# MODE_REQ==1: set video mode to 640x480 (4:3) or 720x480 (16:9) @60hz, and run COMMAND
# MODE_REQ==4: set video mode to 1024x768 (4:3) or 1280x720 (16:9) @60hz, and run COMMAND

# MODE_REQ=="CEA-#": set video mode to CEA mode #
# MODE_REQ=="DMT-#": set video mode to DMT mode #
# MODE_REQ=="PAL/NTSC-RATIO": set mode to SD output with RATIO of 4:3 / 16:10 or 16:9

# note that mode switching only happens if the monitor reports the modes as available (via tvservice)
# and the requested mode differs from the currently active mode

# if savename is included, that is used for loading and saving of video output modes as well as dispmanx settings
# for the current COMMAND. If omitted, the binary name is used as a key for the loading and saving. The savename is
# also displayed in the video output menu (detailed below), so for our purposes we send the emulator module id, which
# is somewhat descriptive yet short.

# on launch this script waits for 1 second for a keypress. If x or m is pressed, a menu is displayed allowing
# the user to set a screenmode for this particular COMMAND. the savename parameter is displayed to the user - we use the module id
# of the emulator we are launching.

ROOTDIR="/opt/retropie"
CONFIGDIR="$ROOTDIR/configs"
LOG="/dev/shm/runcommand.log"

RUNCOMMAND_CONF="$CONFIGDIR/all/runcommand.cfg"
VIDEO_CONF="$CONFIGDIR/all/videomodes.cfg"
APPS_CONF="$CONFIGDIR/all/emulators.cfg"
DISPMANX_CONF="$CONFIGDIR/all/dispmanx.cfg"
RETRONETPLAY_CONF="$CONFIGDIR/all/retronetplay.cfg"

TVSERVICE="/opt/vc/bin/tvservice"

declare -A MODE_MAP
declare -A MODE

MODE_MAP[1-CEA-4:3]="CEA-1"
MODE_MAP[1-DMT-4:3]="DMT-4"
MODE_MAP[1-CEA-16:9]="CEA-1"

MODE_MAP[4-CEA-4:3]="DMT-16"
MODE_MAP[4-DMT-4:3]="DMT-16"
MODE_MAP[4-CEA-16:9]="CEA-4"

source "$ROOTDIR/lib/inifuncs.sh"

function get_config() {
    if [[ -f "$RUNCOMMAND_CONF" ]]; then
        iniConfig " = " '"' "$RUNCOMMAND_CONF"
        iniGet "governor"
        GOVERNOR="$ini_value"
        iniGet "use_art"
        USE_ART="$ini_value"
        [[ -z "$(which fbi)" ]] && USE_ART=0
        iniGet "DISABLE_JOYSTICK"
        DISABLE_JOYSTICK="$ini_value"
        iniGet "DISABLE_MENU"
        DISABLE_MENU="$ini_value"
        [[ "$DISABLE_MENU" -eq 1 ]] && DISABLE_JOYSTICK=1
    fi

    if [[ -f "$TVSERVICE" ]]; then
        HAS_TVS=1
    else
        HAS_TVS=0
    fi
}

function start_joy2key() {
    [[ "$DISABLE_JOYSTICK" -eq 1 ]] && return
    # get the first joystick device (if not already set)
    [[ -z "$__joy2key_dev" ]] && JOY2KEY_DEV="$(ls -1 /dev/input/js* 2>/dev/null | head -n1)"
    # if joy2key.py is installed run it with cursor keys for axis, and enter + tab for buttons 0 and 1
    if [[ -f "$ROOTDIR/supplementary/runcommand/joy2key.py" && -n "$JOY2KEY_DEV" ]] && ! pgrep -f joy2key.py >/dev/null; then

        # call joy2key.py: arguments are curses capability names or hex values starting with '0x'
        # see: http://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html
        "$ROOTDIR/supplementary/runcommand/joy2key.py" "$JOY2KEY_DEV" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09 &
        JOY2KEY_PID=$!
    fi
}

function stop_joy2key() {
    if [[ -n "$JOY2KEY_PID" ]]; then
        kill -INT "$JOY2KEY_PID"
    fi
}


function get_params() {
    MODE_REQ="$1"
    [[ -z "$MODE_REQ" ]] && exit 1

    COMMAND="$2"
    [[ -z "$COMMAND" ]] && exit 1

    CONSOLE_OUT=0
    # if the COMMAND is _SYS_, or _PORT_ arg 3 should be system name, and arg 4 rom/game, and we look up the configured system for that combination
    if [[ "$COMMAND" == "_SYS_" || "$COMMAND" == "_PORT_" ]]; then
        # if the rom is actually a special +Start System.sh script, we should launch the script directly.
        if [[ "$4" =~ \/\+Start\ (.+)\.sh$ ]]; then
            # extract emulator from the name (and lowercase it)
            EMULATOR=${BASH_REMATCH[1],,}
            IS_SYS=0
            COMMAND="bash \"$4\""
            SYSTEM="$3"
        else
            IS_SYS=1
            SYSTEM="$3"
            ROM="$4"
            if [[ "$COMMAND" == "_PORT_" ]]; then
                CONF_ROOT="$CONFIGDIR/ports/$SYSTEM"
                EMU_CONF="$CONF_ROOT/emulators.cfg"
                IS_PORT=1
            else
                CONF_ROOT="$CONFIGDIR/$SYSTEM"
                EMU_CONF="$CONF_ROOT/emulators.cfg"
                IS_PORT=0
            fi
            get_sys_command "$SYSTEM" "$ROM"
        fi
    else
        IS_SYS=0
        CONSOLE_OUT=1
        EMULATOR="$3"
        # if we have an emulator name (such as module_id) we use that for storing/loading parameters for video output/dispmanx
        # if the parameter is empty we use the name of the binary (to avoid breakage with out of date emulationstation configs)
        [[ -z "$EMULATOR" ]] && EMULATOR="${COMMAND/% */}"
    fi

    NETPLAY=0
}

function get_save_vars() {
    # convert emulator name / binary to a names usable as variables in our config files
    SAVE_EMU=${EMULATOR//\//_}
    SAVE_EMU=${SAVE_EMU//[^a-zA-Z0-9_\-]/}
    SAVE_EMU_RENDER="${SAVE_EMU}_render"
    FB_SAVE_EMU="${SAVE_EMU}_fb"
    SAVE_ROM=r$(echo "$COMMAND" | md5sum | cut -d" " -f1)
    FB_SAVE_ROM="${SAVE_ROM}_fb"
}

function get_all_modes() {
    local group
    for group in CEA DMT; do
        while read -r line; do
            local id=$(echo $line | grep -oE "mode [0-9]*" | cut -d" " -f2)
            local info=$(echo $line | cut -d":" -f2-)
            info=${info/ /}
            if [[ -n "$id" ]]; then
                MODE_ID+=($group-$id)
                MODE[$group-$id]="$info"
            fi
        done < <($TVSERVICE -m $group)
    done
    local aspect
    for group in "NTSC" "PAL"; do
        for aspect in "4:3" "16:10" "16:9"; do
            MODE_ID+=($group-$aspect)
            MODE[$group-$aspect]="SDTV - $group-$aspect"
        done
    done
}

function get_mode_info() {
    local status="$($TVSERVICE -s)"
    local temp
    local mode_info=()

    # get mode type / id
    if [[ "$status" =~ (PAL|NTSC) ]]; then
        temp=($(echo "$status" | grep -oE "(PAL|NTSC) (4:3|16:10|16:9)"))
    else
        temp=($(echo "$status" | grep -oE "(CEA|DMT) \([0-9]+\)"))
    fi
    mode_info[0]="${temp[0]}"
    mode_info[1]="${temp[1]//[()]/}"

    # get mode resolution
    temp=$(echo "$status" | cut -d"," -f2 | grep -oE "[0-9]+x[0-9]+")
    temp=(${temp/x/ })
    mode_info[2]="${temp[0]}"
    mode_info[3]="${temp[1]}"

    # get aspect ratio
    temp=$(echo "$status" | grep -oE "([0-9]+:[0-9]+)")
    mode_info[4]="$temp"

    # get refresh rate
    temp=$(echo "$status" | grep -oE "[0-9\.]+Hz" | cut -d"." -f1)
    mode_info[5]="$temp"

    echo "${mode_info[@]}"
}

function load_mode_defaults() {
    local temp
    MODE_ORIG=()

    if [[ $HAS_TVS -eq 1 ]]; then
        # get current mode / aspect ratio
        MODE_ORIG=($(get_mode_info))
        MODE_CUR="$MODE_ORIG"
        MODE_ORIG_ID="${MODE_ORIG[0]}-${MODE_ORIG[1]}"

        # get default mode for requested mode of 1 or 4
        if [[ "$MODE_REQ" == "0" ]]; then
            MODE_REQ_ID="$MODE_ORIG_ID"
        elif [[ $MODE_REQ =~ (1|4) ]]; then
            # if current aspect is anything else like 5:4 / 10:9 just choose a 4:3 mode
            local aspect="${MODE_ORIG[4]}"
            [[ "$aspect" =~ (4:3|16:9) ]] || aspect="4:3"
            temp="${MODE_REQ}-${MODE_ORIG[0]}-$aspect"
            MODE_REQ_ID="${MODE_MAP[$temp]}"
        else
            MODE_REQ_ID="$MODE_REQ"
        fi
    fi

    # get default fb_res (if not running on X)
    FB_ORIG=""
    if [[ -z "$DISPLAY" ]]; then
        FB_ORIG="$(fbset)"
        FB_ORIG="${FB_ORIG##*mode \"}"
        FB_ORIG="${FB_ORIG%%\"*}"
    fi

    MODE_DEF_EMU=""
    MODE_DEF_ROM=""
    FB_DEF_EMU=""
    FB_DEF_ROM=""

    # default retroarch render res to config file
    RENDER_RES="config"

    if [[ -f "$VIDEO_CONF" ]]; then
        # local default video modes for emulator / rom
        iniConfig " = " '"' "$VIDEO_CONF"
        iniGet "$SAVE_EMU"
        if [[ -n "$ini_value" ]]; then
            MODE_DEF_EMU="$ini_value"
            MODE_REQ_ID="$MODE_DEF_EMU"
        fi

        iniGet "$SAVE_ROM"
        if [[ -n "$ini_value" ]]; then
            MODE_DEF_ROM="$ini_value"
            MODE_REQ_ID="$MODE_DEF_ROM"
        fi

        if [[ -z "$DISPLAY" ]]; then
            # load default framebuffer res for emulator / rom
            iniGet "$FB_SAVE_EMU"
            if [[ -n "$ini_value" ]]; then
                FB_DEF_EMU="$ini_value"
                FB_NEW="$FB_DEF_EMU"
            fi

            iniGet "$FB_SAVE_ROM"
            if [[ -n "$ini_value" ]]; then
                FB_DEF_ROM="$ini_value"
                FB_NEW="$FB_DEF_ROM"
            fi
        fi

        iniGet "$SAVE_EMU_RENDER"
        if [[ -n "$ini_value" ]]; then
            RENDER_RES="$ini_value"
        fi
    fi
}

function main_menu() {
    local save
    local cmd
    local choice

    [[ -z "$rom_bn" ]] && rom_bn="game/rom"
    [[ -z "$SYSTEM" ]] && SYSTEM="emulator/port"

    while true; do

        local options=()
        if [[ $IS_SYS -eq 1 ]]; then
            options+=(
                1 "Select default emulator for $SYSTEM ($emulator_def_sys)"
                2 "Select emulator for ROM ($emulator_def_rom)"
            )
            [[ -n "$emulator_def_rom" ]] && options+=(3 "Remove emulator choice for ROM")
        fi

        if [[ $HAS_TVS -eq 1 ]]; then
            options+=(
                4 "Select default video mode for $EMULATOR ($MODE_DEF_EMU)"
                5 "Select video mode for $EMULATOR + rom ($MODE_DEF_ROM)"
            )
            [[ -n "$MODE_DEF_EMU" ]] && options+=(6 "Remove video mode choice for $EMULATOR")
            [[ -n "$MODE_DEF_ROM" ]] && options+=(7 "Remove video mode choice for $EMULATOR + ROM")
        fi

        if [[ "$COMMAND" =~ retroarch ]]; then
            options+=(
                8 "Select RetroArch render res for $EMULATOR ($RENDER_RES)"
                9 "Edit custom RetroArch config for this ROM"
            )
        elif [[ -z "$DISPLAY" ]]; then
            options+=(
                10 "Select framebuffer res for $EMULATOR ($FB_DEF_EMU)"
                11 "Select framebuffer res for $EMULATOR + ROM ($FB_DEF_ROM)"
            )
            [[ -n "$FB_DEF_EMU" ]] && options+=(12 "Remove framebuffer res choice for $EMULATOR")
            [[ -n "$FB_DEF_ROM" ]] && options+=(13 "Remove framebuffer res choice for $EMULATOR + ROM")
        fi

        options+=(X "Launch")

        if [[ "$COMMAND" =~ retroarch ]]; then
            options+=(L "Launch with verbose logging")
            options+=(Z "Launch with netplay enabled")
        fi

        options+=(Q "Exit (without launching)")

        local temp_mode
        if [[ $HAS_TVS -eq 1 ]]; then
            temp_mode="${MODE[$MODE_REQ_ID]}"
        else
            temp_mode="n/a"
        fi
        cmd=(dialog --nocancel --menu "System: $SYSTEM\nEmulator: $EMULATOR\nVideo Mode: $temp_mode\nROM: $rom_bn"  22 76 16 )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        case $choice in
            1)
                choose_app
                get_save_vars
                load_mode_defaults
                ;;
            2)
                choose_app "$appsave"
                get_save_vars
                load_mode_defaults
                ;;
            3)
                sed -i "/$appsave/d" "$APPS_CONF"
                get_sys_command "$SYSTEM" "$ROM"
                ;;
            4)
                choose_mode "$SAVE_EMU" "$MODE_DEF_EMU"
                load_mode_defaults
                ;;
            5)
                choose_mode "$SAVE_ROM" "$MODE_DEF_ROM"
                load_mode_defaults
                ;;
            6)
                sed -i "/$SAVE_EMU/d" "$VIDEO_CONF"
                load_mode_defaults
                ;;
            7)
                sed -i "/$SAVE_ROM/d" "$VIDEO_CONF"
                load_mode_defaults
                ;;
            8)
                choose_render_res "$SAVE_EMU_RENDER"
                ;;
            9)
                touch "$ROM.cfg"
                cmd=(dialog --editbox "$ROM.cfg" 22 76)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                [[ -n "$choice" ]] && echo "$choice" >"$ROM.cfg"
                [[ ! -s "$ROM.cfg" ]] && rm "$ROM.cfg"
                ;;
            10)
                choose_fb_res "$FB_SAVE_EMU" "$FB_DEF_EMU"
                load_mode_defaults
                ;;
            11)
                choose_fb_res "$FB_SAVE_ROM" "$FB_DEF_ROM"
                load_mode_defaults
                ;;
            12)
                sed -i "/$FB_SAVE_EMU/d" "$VIDEO_CONF"
                load_mode_defaults
                ;;
            13)
                sed -i "/$FB_SAVE_ROM/d" "$VIDEO_CONF"
                load_mode_defaults
                ;;
            Z)
                NETPLAY=1
                break
                ;;
            X)
                return 0
                ;;
            L)
                COMMAND+=" --verbose"
                return 0
                ;;
            Q)
                return 1
                ;;
        esac
    done
    return 0
}

function choose_mode() {
    local save="$1"
    local default="$2"
    options=()
    local key
    for key in ${MODE_ID[@]}; do
        options+=("$key" "${MODE[$key]}")
    done
    local cmd=(dialog --default-item "$default" --menu "Choose video output mode"  22 76 16 )
    MODE_REQ_ID=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$MODE_REQ_ID" ]] && return

    iniConfig " = " '"' "$VIDEO_CONF"
    iniSet "$save" "$MODE_REQ_ID"
}

function choose_app() {
    local save="$1"
    local default
    local default_id
    if [[ -n "$save" ]]; then
        default="$EMULATOR"
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
    done < <(sort "$EMU_CONF")
    if [[ -z "${options[*]}" ]]; then
        dialog --msgbox "No emulator options found for $SYSTEM - have you installed any snes emulators yet? Do you have a valid $EMU_CONF ?" 20 60 >/dev/tty
        exit 1
    fi
    local cmd=(dialog --default-item "$default_id" --menu "Choose default emulator"  22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        if [[ -n "$save" ]]; then
            iniConfig " = " '"' "$APPS_CONF"
            iniSet "$save" "${apps[$choice]}"
        else
            iniConfig " = " '"' "$EMU_CONF"
            iniSet "default" "${apps[$choice]}"
        fi
        get_sys_command "$SYSTEM" "$ROM"
    fi
}

function choose_render_res() {
    local save="$1"
    local res=(
        "320x240"
        "640x480"
        "800x600"
        "960x720"
        "1280x960"
    )
    local i=1
    local item
    local options=()
    for item in "${res[@]}"; do
        options+=($i "$item")
        ((i++))
    done
    options+=(
        O "Use video output resolution"
        C "Use config file resolution"
    )
    local cmd=(dialog --menu "Choose RetroArch render resolution" 22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return
    case "$choice" in
        O)
            RENDER_RES="output"
            ;;
        C)
            RENDER_RES="config"
            ;;
        *)
            RENDER_RES="${res[$choice-1]}"
            ;;
    esac

    iniConfig " = " '"' "$VIDEO_CONF"
    iniSet "$save" "$RENDER_RES"
}

function choose_fb_res() {
    local save="$1"
    local default="$2"
    local res=(
        "320x240"
        "640x480"
        "960x720"
        "1280x960"
    )
    local i=1
    local item
    local options=()
    for item in "${res[@]}"; do
        options+=($i "$item")
        ((i++))
    done
    local cmd=(dialog --default-item "$default" --menu "Choose framebuffer resolution (Useful for X and console apps)" 22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return
    fb_res="${res[$choice-1]}"

    iniConfig " = " '"' "$VIDEO_CONF"
    iniSet "$save" "$fb_res"
}

function switch_fb_res() {
    local res=(${1/x/ })
    local res_x=${res[0]}
    local res_y=${res[1]}
    if [[ -z "$res_x" || -z "$res_y" ]]; then
        fbset --all -depth 8
        fbset --all -depth 16
    else
        fbset --all -depth 8
        fbset --all --geometry $res_x $res_y $res_x $res_y 16
    fi
}

function mode_switch() {
    local mode_id="$1"

    # if the requested mode is the same as the current mode don't switch
    [[ "$mode_id" == "${MODE_CUR[0]}-${MODE_CUR[1]}" ]] && return 1

    local mode_id=(${mode_id/-/ })

    if [[ "${mode_id[0]}" == "PAL" ]] || [[ "${mode_id[0]}" == "NTSC" ]]; then
        $TVSERVICE -c "${mode_id[*]}" >/dev/null
    else
        $TVSERVICE -e "${mode_id[*]}" >/dev/null
    fi

    # if we have switched mode, switch the framebuffer resolution also
    if [[ $? -eq 0 ]]; then
        sleep 1
        MODE_CUR=($(get_mode_info))
        [[ -z "$FB_NEW" ]] && FB_NEW="${MODE_CUR[2]}x${MODE_CUR[3]}"
        return 0
    fi

    return 1
}

function restore_fb() {
    sleep 1
    switch_fb_res "$FB_ORIG"
}

function config_dispmanx() {
    local name="$1"
    # if we have a dispmanx conf file and $name is in it (as a variable) and set to 1,
    # change the library path to load dispmanx sdl first
    if [[ -f "$DISPMANX_CONF" ]]; then
        iniConfig " = " '"' "$DISPMANX_CONF"
        iniGet "$name"
        [[ "$ini_value" == "1" ]] && COMMAND="SDL1_VIDEODRIVER=dispmanx $COMMAND"
    fi
}

function retroarch_append_config() {
    # only for retroarch emulators
    [[ ! "$COMMAND" =~ "retroarch" ]] && return

    # make sure tmp folder exists for unpacking archives
    mkdir -p "/tmp/retroarch"

    local conf="/dev/shm/retroarch.cfg"
    rm -f "$conf"
    touch "$conf"
    if [[ "$HAS_TVS" -eq 1 && "${MODE_CUR[5]}" -gt 0 ]]; then
        # set video_refresh_rate in our config to the same as the screen refresh
        [[ -n "${MODE_CUR[5]}" ]] && echo "video_refresh_rate = ${MODE_CUR[5]}" >>"$conf"
    fi

    local dim
    # if our render resolution is "config", then we don't set anything (use the value in the retroarch.cfg)
    if [[ "$RENDER_RES" != "config" ]]; then
        if [[ "$RENDER_RES" == "output" ]]; then
            dim=(0 0)
        else
            dim=(${RENDER_RES/x/ })
        fi
        echo "video_fullscreen_x = ${dim[0]}" >>"$conf"
        echo "video_fullscreen_y = ${dim[1]}" >>"$conf"
    fi

    # if the ROM has a custom configuration then append that too
    if [[ -f "$ROM.cfg" ]]; then
        conf+="'|'\"$ROM.cfg\""
    fi

    # if we already have an existing appendconfig parameter, we need to add our configs to that
    if [[ "$COMMAND" =~ "--appendconfig" ]]; then
        COMMAND=$(echo "$COMMAND" | sed "s#\(--appendconfig *[^ $]*\)#\1'|'$conf#")
    else
        COMMAND+=" --appendconfig $conf"
    fi

    # append any NETPLAY configuration
    if [[ $NETPLAY -eq 1 ]] && [[ -f "$RETRONETPLAY_CONF" ]]; then
        source "$RETRONETPLAY_CONF"
        COMMAND+=" -$__netplaymode $__netplayhostip_cfile --port $__netplayport --frames $__netplayframes --nick $__netplaynickname"
    fi
}

function set_governor() {
    governor_old=()
    # we save the previous states first, as setting any cpuX on the RPI will also set the value for the other cores
    # which would cause us to save the wrong state for cpu1/2/3 after setting cpu0. On the RPI we could just process
    # cpu0, but this code needs to work on other platforms that do support a "per core" CPU governor.
    for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
        governor_old+=($(<$cpu))
    done
    for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
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
    local system="$1"
    local rom="$2"

    rom_bn="${rom##*/}"
    rom_bn="${rom_bn%.*}"

    appsave=a$(echo "$system$rom" | md5sum | cut -d" " -f1)

    if [[ ! -f "$EMU_CONF" ]]; then
        echo "No config found for system $system"
        exit 1
    fi

    iniConfig " = " '"' "$EMU_CONF"
    iniGet "default"
    if [[ -z "$ini_value" ]]; then
        echo "No default emulator found for system $system"
        start_joy2key
        choose_app
        stop_joy2key
        get_sys_command "$system" "$rom"
        return
    fi

    EMULATOR="$ini_value"
    emulator_def_sys="$EMULATOR"

    # get system & rom specific app if set
    if [[ -f "$APPS_CONF" ]]; then
        iniConfig " = " '"' "$APPS_CONF"
        iniGet "$appsave"
        emulator_def_rom="$ini_value"
        [[ -n "$ini_value" ]] && EMULATOR="$ini_value"
    fi

    # get the app commandline
    iniConfig " = " '"' "$EMU_CONF"
    iniGet "$EMULATOR"
    COMMAND="$ini_value"

    # replace tokens
    COMMAND="${COMMAND/\%ROM\%/\"$rom\"}"
    COMMAND="${COMMAND/\%BASENAME\%/\"$rom_bn\"}"

    # special case to get the last 2 folders for quake games for the -game parameter
    # remove everything up to /quake/
    local quake_dir="${rom##*/quake/}"
    # remove filename
    local quake_dir="${quake_dir%/*}"
    COMMAND="${COMMAND/\%QUAKEDIR\%/\"$quake_dir\"}"

    # if it starts with CON: it is a console application (so we don't redirect stdout later)
    if [[ "$COMMAND" == CON:* ]]; then
        # remove CON:
        COMMAND="${COMMAND:4}"
        CONSOLE_OUT=1
    fi
}

function show_launch() {
    local images=()

    if [[ "$USE_ART" -eq 1 ]]; then
        # if using art look for images in paths for es art.
        images+=(
            "$HOME/RetroPie/roms/$SYSTEM/images/${rom_bn}-image"
            "$HOME/.emulationstation/downloaded_images/$SYSTEM/${rom_bn}-image"
        )
    fi

    # look for custom launching images
    [[ $IS_SYS -eq 1 ]] && images+=("$CONF_ROOT/launching")
    [[ $IS_PORT -eq 1 ]] && images+=("$CONFIGDIR/ports/launching")
    images+=(
        "$CONFIGDIR/all/launching"
    )

    local image
    local path
    local ext
    for path in "${images[@]}"; do
        for ext in jpg png; do
            if [[ -f "$path.$ext" ]]; then
                image="$path.$ext"
                break 2
            fi
        done
    done

    if [[ -z "$DISPLAY" && -n "$image" ]]; then
        fbi -1 -t 2 -noverbose -a "$image" </dev/tty &>/dev/null
    elif [[ "$DISABLE_MENU" -ne 1 && "$USE_ART" -ne 1 ]]; then
        local launch_name
        if [[ -n "$rom_bn" ]]; then
            launch_name="$rom_bn ($EMULATOR)"
        else
            launch_name="$EMULATOR"
        fi
        DIALOGRC="$CONFIGDIR/all/runcommand-launch-dialog.cfg" dialog --infobox "\nLaunching $launch_name ...\n\nPress a button to configure\n\nErrors are logged to $LOG" 9 60
    fi
}

function check_menu() {
    local dont_launch=0
    start_joy2key
    # check for key pressed to enter configuration
    IFS= read -s -t 2 -N 1 key </dev/tty
    if [[ -n "$key" ]]; then
        if [[ $HAS_TVS -eq 1 ]]; then
            get_all_modes
        fi
        tput cnorm
        main_menu
        dont_launch=$?
        tput civis
        clear
    fi
    stop_joy2key
    return $dont_launch
}

# calls script with parameters SYSTEM, EMULATOR, ROM, and commandline
function user_script() {
    local script="$CONFIGDIR/all/$1"
    if [[ -f "$script" ]]; then
        bash "$script" "$SYSTEM" "$EMULATOR" "$ROM" "$COMMAND" </dev/tty 2>>"$LOG"
    fi
}

get_config

get_params "$@"

# turn off cursor and clear screen
tput civis
clear

rm -f "$LOG"
echo -e "$SYSTEM\n$EMULATOR\n$ROM\n$COMMAND" >/dev/shm/runcommand.info
user_script "runcommand-onstart.sh"

get_save_vars

load_mode_defaults

show_launch

if [[ "$DISABLE_MENU" -ne 1 ]]; then
    if ! check_menu; then
        tput cnorm
        exit 0
    fi
fi

mode_switch "$MODE_REQ_ID"

[[ -n "$FB_NEW" ]] && switch_fb_res "$FB_NEW"

config_dispmanx "$SAVE_EMU"

# switch to configured cpu scaling governor
[[ -n "$GOVERNOR" ]] && set_governor "$GOVERNOR"

retroarch_append_config

# launch the command
echo -e "Parameters: $@\nExecuting: $COMMAND" >>"$LOG"
if [[ "$CONSOLE_OUT" -eq 1 ]]; then
    # turn cursor on
    tput cnorm
    eval $COMMAND </dev/tty 2>>"$LOG"
    tput civis
else
    eval $COMMAND </dev/tty &>>"$LOG"
fi

clear

# remove tmp folder for unpacked archives if it exists
rm -rf "/tmp/retroarch"

# restore default cpu scaling governor
[[ -n "$GOVERNOR" ]] && restore_governor

# if we switched mode - restore preferred mode
mode_switch "$MODE_ORIG_ID"

# reset/restore framebuffer res (if it was changed)
[[ -n "$FB_NEW" ]] && restore_fb

[[ "$COMMAND" =~ retroarch ]] && retroarchIncludeToEnd "$CONF_ROOT/retroarch.cfg"

user_script "runcommand-onend.sh"

## if we are not being run from emulationstation (get parent of parent), turn the cursor back on.
if [[ "$(ps -o comm= -p $(ps -o ppid= -p $PPID))" != "emulationstatio" ]]; then
    tput cnorm
fi

exit 0
