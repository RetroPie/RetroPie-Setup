#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

## @file supplementary/runcommand/runcommand.sh
## @brief runcommand launching script
## @copyright GPLv3
## @details
## @par Usage
##
## `runcommand.sh VIDEO_MODE COMMAND SAVE_NAME`
##
## or
##
## `runcommand.sh VIDEO_MODE _SYS_/_PORT_ SYSTEM ROM`
##
## Video mode switching is supported on X11, KMS and Raspberry Pi (legacy graphics) systems
##
## Automatic video mode selection (all):
##
## * VIDEO_MODE = 0: use the current video mode
##
## Automatic video mode (Raspberry Pi legacy graphics):
##
## * VIDEO_MODE = 1: set video mode to 640x480 (4:3) or 720x480 (16:9) @60hz
## * VIDEO_MODE = 4: set video mode to 1024x768 (4:3) or 1280x720 (16:9) @60hz
##
## Manual video mode selection (Raspberry Pi legacy graphics):
##
## * VIDEO_MODE = "CEA-#": set video mode to CEA mode #
## * VIDEO_MODE = "DMT-#": set video mode to DMT mode #
## * VIDEO_MODE = "PAL/NTSC-RATIO": set mode to SD output with RATIO of 4:3 / 16:10 or 16:9
##
## Manual video mode selection (KMS):
##
## * VIDEO_MODE = "CRTCID-MODEID": set video mode to CRTC connector id and mode id
##
## Manual video mode selection (X11):
##
## * VIDEO_MODE = "OUTPUT:MODEID": set video mode to connected output name and mode index
##
## @note
## Video mode switching only happens if the monitor reports the modes as available
## (via tvservice) and the requested mode differs from the currently active mode
##
## If `_SYS_` or `_PORT_` is provided for the second parameter, the commandline
## will be extracted from `/opt/retropie/configs/SYSTEM/emulators.cfg` with
## `%ROM%` `%BASENAME%` being replaced with the ROM parameter. This is the
## default mode used when launching in RetroPie so the user can switch emulator
## used as well as other options from the runcommand GUI.
##
## If SAVE_NAME is included, that is used for loading and saving of video output
## modes as well as SDL1 dispmanx settings for the current COMMAND. If omitted,
## the binary name is used as a key for the loading and saving. The savename is
## also displayed in the video output menu (detailed below), so for our purposes
## we send the emulator module id, which is somewhat descriptive yet short.
##
## On launch this script waits for 2 second for a key or joystick press. If
## pressed the GUI is shown, where a user can set video modes, default emulators
## and other options (depending what is being launched).

ROOTDIR="/opt/retropie"
CONFIGDIR="$ROOTDIR/configs"
LOG="/dev/shm/runcommand.log"

RUNCOMMAND_CONF="$CONFIGDIR/all/runcommand.cfg"
VIDEO_CONF="$CONFIGDIR/all/videomodes.cfg"
EMU_CONF="$CONFIGDIR/all/emulators.cfg"
DISPMANX_CONF="$CONFIGDIR/all/dispmanx.cfg"
RETRONETPLAY_CONF="$CONFIGDIR/all/retronetplay.cfg"

# modesetting tools
TVSERVICE="/opt/vc/bin/tvservice"
KMSTOOL="$ROOTDIR/supplementary/mesa-drm/modetest"
XRANDR="xrandr"

source "$ROOTDIR/lib/inifuncs.sh"

function get_config() {
    declare -Ag MODE_MAP

    MODE_MAP[1-CEA-4:3]="CEA-1"
    MODE_MAP[1-DMT-4:3]="DMT-4"
    MODE_MAP[1-CEA-16:9]="CEA-1"

    MODE_MAP[4-CEA-4:3]="DMT-16"
    MODE_MAP[4-DMT-4:3]="DMT-16"
    MODE_MAP[4-CEA-16:9]="CEA-4"

    if [[ -f "$RUNCOMMAND_CONF" ]]; then
        iniConfig " = " '"' "$RUNCOMMAND_CONF"
        iniGet "governor"
        GOVERNOR="$ini_value"
        iniGet "use_art"
        USE_ART="$ini_value"
        iniGet "disable_joystick"
        DISABLE_JOYSTICK="$ini_value"
        iniGet "disable_menu"
        DISABLE_MENU="$ini_value"
        iniGet "image_delay"
        IMAGE_DELAY="$ini_value"
        [[ -z "$IMAGE_DELAY" ]] && IMAGE_DELAY=2
    fi

    if [[ -n "$DISPLAY" ]] && $XRANDR &>/dev/null; then
        HAS_MODESET="x11"
    # copy kms tool output to global variable to avoid multiple invocations
    elif KMS_BUFFER="$($KMSTOOL -r 2>/dev/null)"; then
        HAS_MODESET="kms"
    elif [[ -f "$TVSERVICE" ]]; then
        HAS_MODESET="tvs"
    fi
}

function start_joy2key() {
    [[ "$DISABLE_JOYSTICK" -eq 1 ]] && return
    # get the first joystick device (if not already set)
    if [[ -c "$__joy2key_dev" ]]; then
        JOY2KEY_DEV="$__joy2key_dev"
    else
        JOY2KEY_DEV="/dev/input/jsX"
    fi
    # if joy2key.py is installed run it with cursor keys for axis, and enter + tab for buttons 0 and 1
    if [[ -f "$ROOTDIR/supplementary/runcommand/joy2key.py" && -n "$JOY2KEY_DEV" ]] && ! pgrep -f joy2key.py >/dev/null; then

        # call joy2key.py: arguments are curses capability names or hex values starting with '0x'
        # see: http://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html
        "$ROOTDIR/supplementary/runcommand/joy2key.py" "$JOY2KEY_DEV" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09
        JOY2KEY_PID=$(pgrep -f joy2key.py)

    # ensure coherency between on-screen prompts and actual button mapping functionality
    sleep 0.3
    fi
}

function stop_joy2key() {
    if [[ -n "$JOY2KEY_PID" ]]; then
        kill "$JOY2KEY_PID"
        JOY2KEY_PID=""
        sleep 1
    fi
}

function get_params() {
    MODE_REQ="$1"
    COMMAND="$2"

    [[ -z "$MODE_REQ" || -z "$COMMAND" ]] && return 1

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
            [[ -z "$SYSTEM" ]] && return 1
        else
            IS_SYS=1
            SYSTEM="$3"
            ROM="$4"
            ROM_BN_EXT="${ROM##*/}"
            ROM_BN="${ROM_BN_EXT%.*}"
            if [[ "$COMMAND" == "_PORT_" ]]; then
                CONF_ROOT="$CONFIGDIR/ports/$SYSTEM"
                EMU_SYS_CONF="$CONF_ROOT/emulators.cfg"
                IS_PORT=1
            else
                CONF_ROOT="$CONFIGDIR/$SYSTEM"
                EMU_SYS_CONF="$CONF_ROOT/emulators.cfg"
                IS_PORT=0
            fi
            SYS_SAVE_ROM_OLD="a$(echo "$SYSTEM$ROM" | md5sum | cut -d" " -f1)"
            SYS_SAVE_ROM="$(clean_name "${SYSTEM}_${ROM_BN}")"
            [[ -z "$SYSTEM" ]] && return 1
            get_sys_command
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
    return 0
}

function clean_name() {
    local name="$1"
    name="${name//\//_}"
    name="${name//[^a-zA-Z0-9_\-]/}"
    echo "$name"
}

function set_save_vars() {
    # convert emulator name / binary to a names usable as variables in our config files
    SAVE_EMU="$(clean_name "$EMULATOR")"
    SAVE_ROM_OLD=r$(echo "$COMMAND" | md5sum | cut -d" " -f1)
    if [[ "$IS_SYS" -eq 1 ]]; then
        SAVE_ROM="${SAVE_EMU}_$(clean_name "$ROM_BN")"
    else
        SAVE_ROM="$SAVE_EMU"
    fi
}

function get_all_tvs_modes() {
    declare -Ag MODE
    local group
    for group in CEA DMT; do
        while read -r line; do
            local id="$(echo "$line" | grep -oE "mode [0-9]*" | cut -d" " -f2)"
            local info="$(echo "$line" | cut -d":" -f2-)"
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

function get_all_kms_modes() {
    declare -Ag MODE
    local default_mode="$(echo "$KMS_BUFFER" | grep -m1 "^Mode:.*driver.*crtc")"
    local crtc="$(echo "$default_mode" | awk '{ print $(NF-1) }')"
    local crtc_encoder="$(echo "$KMS_BUFFER" | grep "Encoder map:" | awk -v crtc="$crtc" '$5 == crtc { print $3 }')"

    local info
    local line
    local mode_id

    # add default mode as fallback in case real mode cannot be mapped
    MODE[def-def]="$(echo "$default_mode" | awk '{--NF --NF --NF; print}' | cut -c7-)"

    while read -r line; do
        # encoder id
        encoder_id="$(echo "$line" | awk '{ print $(NF-1) }')"

        # only match encoders that are linked to the currently active crtc
        if [[ "$encoder_id" == "$crtc_encoder" ]]; then
            # mode id
            mode_id="$(echo "$line" | awk '{ print $NF }')"

            # make output more human-readable
            info="$(echo "$line" | awk '{--NF --NF --NF; print}' | cut -c7-)"

            # populate resolution into arrays (using mapped crtc encoder value)
            MODE_ID+=($crtc-$mode_id)
            MODE[$crtc-$mode_id]="$info"

            # if string matches default mode, add a special mapped entry
            [[ "$default_mode" =~ "$info" ]] && MODE[map-map]="$crtc $mode_id"
        fi
    done < <(echo "$KMS_BUFFER" | grep "Mode:" | grep "connector")
}

function get_all_x11_modes()
{
        declare -Ag MODE
        local id
        local info
        local line
        local verbose_info=()
        local output="$($XRANDR --verbose | grep " connected" | awk '{ print $1 }')"

        while read -r line; do
            # scan for line that contains bracketed mode id
            id="$(echo "$line" | awk '{ print $2 }' | grep "([0-9]\{1,\}x[0-9]\{1,\})")"

            if [[ -n "$id" ]]; then
                # strip brackets from mode id
                id="$(echo ${id:1:-1})"

                # extract extended details
                verbose_info=($(echo "$line" | awk '{ for (i=3; i<=NF; ++i) print $i }'))

                # extract x/y resolution, vertical refresh rate and append details
                read -r line
                info="$(echo "$line" | awk '{ print $3 }')"
                read -r line
                info+="x$(echo "$line" | awk '{ print $3 }') @ $(echo "$line" | awk '{ print $NF }') ("${verbose_info[*]}")"

                # populate resolution into arrays
                MODE_ID+=($output:$id)
                MODE[$output:$id]="$info"
            fi
        done < <($XRANDR --verbose)
}

function get_tvs_mode_info() {
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

function get_kms_mode_info() {
    local mode_id=(${1/-/ })
    local mode_info=()
    local status

    if [[ -z "${mode_id[*]}" ]]; then
	if [[ -n "${MODE[map-map]}" ]]; then
            # use mapped mode directly
            mode_id=(${MODE[map-map]})
        else
            # use fallback mode
            mode_id=(def def)
        fi
    fi

    # split resolution
    status=(${MODE[${mode_id[0]}-${mode_id[1]}]/x/ })

    # get crtc id
    mode_info[0]="${mode_id[0]}"

    # get mode id
    mode_info[1]="${mode_id[1]}"

    # get mode resolution
    mode_info[2]="${status[0]}"
    mode_info[3]="${status[1]}"

    # get aspect ratio
    mode_info[4]="${status[5]}"

    # get refresh rate
    mode_info[5]="${status[3]}"

    echo "${mode_info[@]}"
}

function get_x11_mode_info() {
    local mode_id=(${1/:/ })
    local mode_info=()
    local status

    if [[ -z "$mode_id" ]]; then
        # determine current output
        mode_id[0]="$($XRANDR --verbose | grep " connected" | awk '{ print $1 }')"
        # determine current mode id & strip brackets
        mode_id[1]="$($XRANDR --verbose | grep " connected" | grep -o "([0-9]\{1,\}x[0-9]\{1,\})")"
        mode_id[1]="$(echo ${mode_id[1]:1:-1})"
    fi

    # mode type corresponds to the currently connected output name
    mode_info[0]="${mode_id[0]}"

    # get mode id
    mode_info[1]="${mode_id[1]}"

    # get status line and split resolution
    status=(${MODE[${mode_id[0]}:${mode_id[1]}]/x/ })

    # get resolution
    mode_info[2]="${status[0]}"
    mode_info[3]="${status[1]}"

    # aspect ratio cannot be determined for X11
    mode_info[4]="n/a"

    # get refresh rate (stripping Hz, rounded to integer)
    mode_info[5]="$(printf '%.0f\n' ${status[3]::-2})"

    echo "${mode_info[@]}"
}

function default_process() {
    local config="$1"
    local mode="$2"
    local key="$3"
    local value="$4"

    iniConfig " = " '"' "$config"
    case "$mode" in
        get)
            iniGet "$key"
            echo "$ini_value"
            ;;
        set)
            iniSet "$key" "$value"
            ;;
        del)
            iniDel "$key"
            ;;
    esac
}

function default_mode() {
    local mode="$1"
    local type="$2"
    local value="$3"

    local key
    case "$type" in
        vid_emu)
            key="$SAVE_EMU"
            ;;
        vid_rom_old)
            key="$SAVE_ROM_OLD"
            ;;
        vid_rom)
            key="$SAVE_ROM"
            ;;
        fb_emu)
            key="${SAVE_EMU}_fb"
            ;;
        fb_rom_old)
            key="${SAVE_ROM_OLD}_fb"
            ;;
        fb_rom)
            key="${SAVE_ROM}_fb"
            ;;
        render)
            key="${SAVE_EMU}_render"
            ;;
    esac
    default_process "$VIDEO_CONF" "$mode" "$key" "$value"
}

function default_emulator() {
    local mode="$1"
    local type="$2"
    local value="$3"

    local key
    local config="$EMU_SYS_CONF"

    case "$type" in
        emu_sys)
            key="default"
            ;;
        emu_cmd)
            key="$EMULATOR"
            ;;
        emu_rom_old)
            key="$SYS_SAVE_ROM_OLD"
            config="$EMU_CONF"
            ;;
        emu_rom)
            key="$SYS_SAVE_ROM"
            config="$EMU_CONF"
            ;;
    esac
    default_process "$config" "$mode" "$key" "$value"
}

function load_mode_defaults() {
    local separator="-"
    [[ "$HAS_MODESET" == "x11" ]] && separator=":"
    local temp
    MODE_ORIG=()


    if [[ -n "$HAS_MODESET" ]]; then
        # populate available modes
        [[ -z "$MODE_ID" ]] && get_all_${HAS_MODESET}_modes

        # get current mode / aspect ratio
        MODE_ORIG=($(get_${HAS_MODESET}_mode_info))
        MODE_CUR=("${MODE_ORIG[@]}")
        MODE_ORIG_ID="${MODE_ORIG[0]}${separator}${MODE_ORIG[1]}"

       if [[ "$MODE_REQ" == "0" ]]; then
            MODE_REQ_ID="$MODE_ORIG_ID"
       elif [[ "$HAS_MODESET" == "tvs" ]]; then
            # get default mode for requested mode of 1 or 4
            if [[ "$MODE_REQ" =~ (1|4) ]]; then
                # if current aspect is anything else like 5:4 / 10:9 just choose a 4:3 mode
                local aspect="${MODE_ORIG[4]}"
                [[ "$aspect" =~ (4:3|16:9) ]] || aspect="4:3"
                temp="${MODE_REQ}-${MODE_ORIG[0]}-$aspect"
                MODE_REQ_ID="${MODE_MAP[$temp]}"
            else
                MODE_REQ_ID="$MODE_REQ"
            fi
        else
            MODE_REQ_ID="$MODE_REQ"
        fi
    fi

    # get default fb_res (if not running on X)
    FB_ORIG=()
    if [[ -z "$DISPLAY" ]]; then
        local status=($(fbset | tr -s '\n'))
        FB_ORIG[0]="${status[3]}"
        FB_ORIG[1]="${status[4]}"
        FB_ORIG[2]="${status[7]}"
    fi

    # default retroarch render res to config file
    RENDER_RES="config"

    local mode
    if [[ -f "$VIDEO_CONF" ]]; then
        # load default video mode for emulator / rom
        mode="$(default_mode get vid_emu)"
        [[ -n "$mode" ]] && MODE_REQ_ID="$mode"

        # get default mode for system + rom combination
        # try the old key first and convert to the new key if found
        mode="$(default_mode get vid_rom_old)"
        if [[ -n "$mode" ]]; then
            default_mode del vid_rom_old
            default_mode set vid_rom "$mode"
            MODE_REQ_ID="$mode"
        else
            mode="$(default_mode get vid_rom)"
            [[ -n "$mode" ]] && MODE_REQ_ID="$mode"
        fi

        if [[ "$HAS_MODESET" == "tvs" ]]; then
            # load default framebuffer res for emulator / rom
            mode="$(default_mode get fb_emu)"
            [[ -n "$mode" ]] && FB_NEW="$mode"

            # get default fb mode for system + rom combination
            # try the old key first and convert to the new key if found
            mode="$(default_mode get fb_rom_old)"
            if [[ -n "$mode" ]]; then
                default_mode del fb_rom_old
                default_mode set fb_rom "$mode"
                FB_NEW="$mode"
            else
                mode="$(default_mode get fb_rom)"
                [[ -n "$mode" ]] && FB_NEW="$mode"
            fi
        fi

        # get default retroarch render resolution for emulator
        mode="$(default_mode get render)"
        [[ -n "$mode" ]] && RENDER_RES="$mode"
    fi
}

function main_menu() {
    local save
    local cmd
    local choice

    local user_menu=0
    [[ -d "$CONFIGDIR/all/runcommand-menu" && -n "$(find "$CONFIGDIR/all/runcommand-menu" -maxdepth 1 -name "*.sh")" ]] && user_menu=1

    [[ -z "$ROM_BN" ]] && ROM_BN="game/rom"
    [[ -z "$SYSTEM" ]] && SYSTEM="emulator/port"

    while true; do

        local options=()
        if [[ "$IS_SYS" -eq 1 ]]; then
            local emu_sys="$(default_emulator get emu_sys)"
            local emu_rom="$(default_emulator get emu_rom)"
            options+=(
                1 "Select default emulator for $SYSTEM ($emu_sys)"
                2 "Select emulator for ROM ($emu_rom)"
            )
            [[ -n "$emu_rom" ]] && options+=(3 "Remove emulator choice for ROM")
        fi

        if [[ -n "$HAS_MODESET" ]]; then
            local vid_emu="$(default_mode get vid_emu)"
            local vid_rom="$(default_mode get vid_rom)"
            options+=(
                4 "Select default video mode for $EMULATOR ($vid_emu)"
                5 "Select video mode for $EMULATOR + rom ($vid_rom)"
            )
            [[ -n "$vid_emu" ]] && options+=(6 "Remove video mode choice for $EMULATOR")
            [[ -n "$vid_rom" ]] && options+=(7 "Remove video mode choice for $EMULATOR + ROM")
        fi

        if [[ "$EMULATOR" == lr-* ]]; then
            if [[ "$HAS_MODESET" == "tvs" ]]; then
                options+=(8 "Select RetroArch render res for $EMULATOR ($RENDER_RES)")
            fi
            options+=(9 "Edit custom RetroArch config for this ROM")
        elif [[ "$HAS_MODESET" == "tvs" ]]; then
            local fb_emu="$(default_mode get fb_emu)"
            local fb_rom="$(default_mode get fb_rom)"
            options+=(
                10 "Select framebuffer res for $EMULATOR ($fb_emu)"
                11 "Select framebuffer res for $EMULATOR + ROM ($fb_rom)"
            )
            [[ -n "$fb_emu" ]] && options+=(12 "Remove framebuffer res choice for $EMULATOR")
            [[ -n "$fb_rom" ]] && options+=(13 "Remove framebuffer res choice for $EMULATOR + ROM")
        fi

        options+=(X "Launch")

        if [[ "$EMULATOR" == lr-* ]]; then
            options+=(L "Launch with verbose logging")
            options+=(Z "Launch with netplay enabled")
        fi

        if [[ "$user_menu" -eq 1 ]]; then
            options+=(U "User Menu")
        fi

        options+=(Q "Exit (without launching)")

        local temp_mode
        if [[ -n "$HAS_MODESET" ]]; then
            temp_mode="${MODE[$MODE_REQ_ID]}"
        else
            temp_mode="n/a"
        fi
        cmd=(dialog --nocancel --menu "System: $SYSTEM\nEmulator: $EMULATOR\nVideo Mode: $temp_mode\nROM: $ROM_BN"  22 76 16 )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        case "$choice" in
            1)
                choose_emulator "emu_sys" "$emu_sys"
                ;;
            2)
                choose_emulator "emu_rom" "$emu_rom"
                ;;
            3)
                default_emulator "del" "emu_rom"
                get_sys_command
                set_save_vars
                load_mode_defaults
                ;;
            4)
                choose_mode "vid_emu" "$vid_emu"
                ;;
            5)
                choose_mode "vid_rom" "$vid_rom"
                ;;
            6)
                default_mode "del" "vid_emu"
                load_mode_defaults
                ;;
            7)
                default_mode "del" "vid_rom"
                load_mode_defaults
                ;;
            8)
                choose_render_res "render" "$RENDER_RES"
                ;;
            9)
                touch "$ROM.cfg"
                cmd=(dialog --editbox "$ROM.cfg" 22 76)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                [[ -n "$choice" ]] && echo "$choice" >"$ROM.cfg"
                [[ ! -s "$ROM.cfg" ]] && rm "$ROM.cfg"
                ;;
            10)
                choose_fb_res "fb_emu" "$fb_emu"
                ;;
            11)
                choose_fb_res "fb_rom" "$fb_rom"
                ;;
            12)
                default_mode "del" "fb_emu"
                load_mode_defaults
                ;;
            13)
                default_mode "del" "fb_rom"
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
            U)
                user_menu
                local ret="$?"
                [[ "$ret" -eq 1 ]] && return 1
                [[ "$ret" -eq 2 ]] && return 0
                ;;
            Q)
                return 1
                ;;
        esac
    done
    return 0
}

function choose_mode() {
    local mode="$1"
    local default="$2"

    local options=()
    local key
    for key in "${MODE_ID[@]}"; do
        options+=("$key" "${MODE[$key]}")
    done
    local cmd=(dialog --default-item "$default" --menu "Choose video output mode"  22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    default_mode set "$mode" "$choice"
    load_mode_defaults
}

function choose_emulator() {
    local mode="$1"
    local default="$2"
    local cancel="$3"

    local default
    local default_id

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
    done < <(sort "$EMU_SYS_CONF")
    if [[ -z "${options[*]}" ]]; then
        dialog --msgbox "No emulator options found for $SYSTEM - Do you have a valid $EMU_SYS_CONF ?" 20 60 >/dev/tty
        stop_joy2key
        exit 1
    fi
    local cmd=(dialog $cancel --default-item "$default_id" --menu "Choose default emulator"  22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    default_emulator set "$mode" "${apps[$choice]}"
    get_sys_command
    set_save_vars
    load_mode_defaults
}

function get_resolutions() {
    local res=(
        "320x224"
        "320x240"
        "400x240"
        "480x320"
        "640x480"
        "720x480"
        "720x576"
        "800x480"
        "800x600"
        "960x720"
        "1024x600"
        "1024x768"
        "1024x800"
        "1280x720"
        "1280x800"
        "1280x960"
        "1280x1024"
        "1360x768"
        "1366x768"
        "1920x1080"
    )
    echo "${res[@]}"
}

function choose_render_res() {
    local mode="$1"
    local default="$2"

    local res=($(get_resolutions))
    local i=1
    local item
    local options=()
    for item in "${res[@]}"; do
        [[ "$item" == "$default" ]] && default="$i"
        options+=($i "$item")
        ((i++))
    done
    options+=(
        O "Use video output resolution"
        C "Use config file resolution"
    )
    [[ "$default" == "output" ]] && default="O"
    [[ "$default" == "config" ]] && default="C"
    local cmd=(dialog --default-item "$default" --menu "Choose RetroArch render resolution" 22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return
    case "$choice" in
        O)
            choice="output"
            ;;
        C)
            choice="config"
            ;;
        *)
            choice="${res[$choice-1]}"
            ;;
    esac

    default_mode set "$mode" "$choice"
    load_mode_defaults
}

function choose_fb_res() {
    local mode="$1"
    local default="$2"

    local res=($(get_resolutions))
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
    choice="${res[$choice-1]}"

    default_mode set "$mode" "$choice"
    load_mode_defaults
}

function user_menu() {
    local default
    local options=()
    local script
    local i=1
    while read -r script; do
        script="${script##*/}"
        script="${script%.*}"
        options+=($i "$script")
        ((i++))
    done < <(find "$CONFIGDIR/all/runcommand-menu" -type f -name "*.sh" | sort)
    local default
    local cmd
    local choice
    local ret
    while true; do
        cmd=(dialog --default-item "$default" --cancel-label "Back" --menu "Choose option"  22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return 0
        default="$choice"
        script="runcommand-menu/${options[choice*2-1]}.sh"
        user_script "$script"
        ret="$?"
        [[ "$ret" -eq 1 || "$ret" -eq 2 ]] && return "$ret"
    done
}

function switch_fb_res() {
    local res=(${1/x/ })
    local res_x="${res[0]}"
    local res_y="${res[1]}"
    local depth="$2"
    [[ -z "$depth" ]] && depth="${FB_ORIG[2]}"

    if [[ -z "$res_x" || -z "$res_y" ]]; then
        fbset --all -depth 8
        fbset --all -depth $depth
    else
        fbset --all -depth 8
        fbset --all --geometry $res_x $res_y $res_x $res_y $depth
    fi
}

function build_xinitrc() {
    local mode="$1"
    local xinitrc="/dev/shm/retropie_xinitrc"

    case "$mode" in
        clear)
            rm -rf "$xinitrc"
            ;;
        build)
            echo "#!/bin/bash" >"$xinitrc"

            # do modesetting (if supported)
            if [[ -n "$HAS_MODESET" ]]; then
                cat >>"$xinitrc" <<_EOF_
XRANDR_OUTPUT="\$($XRANDR --verbose | grep " connected" | awk '{ print \$1 }')"
$XRANDR --output \$XRANDR_OUTPUT --mode ${MODE_CUR[2]}x${MODE_CUR[3]} --refresh ${MODE_CUR[5]}
echo "Set mode ${MODE_CUR[2]}x${MODE_CUR[3]}@${MODE_CUR[5]}Hz on \$XRANDR_OUTPUT"
_EOF_
            fi

            # echo command line for runcommand log
            cat >>"$xinitrc" <<_EOF_
echo -e "\nExecuting (via xinit): "${COMMAND//\$/\\\$}"\n"
${COMMAND//\$/\\\$}
_EOF_
            chmod +x "$xinitrc"

            # rewrite command to launch our xinit script (if not startx)
            if ! [[ "$COMMAND" =~ ^startx ]]; then
                COMMAND="xinit $xinitrc"
            fi

            # workaround for launching xserver on correct/user owned tty
            # see https://github.com/RetroPie/RetroPie-Setup/issues/1805
            if [[ -n "$TTY" ]]; then
                COMMAND="$COMMAND -- vt$TTY -keeptty"
            fi
            ;;
    esac
}

function mode_switch() {
    local command_prefix
    local separator="-"
    # X11 uses hypens in connector names
    [[ $HAS_MODESET == "x11" ]] && separator=":"
    local mode_id=(${1/${separator}/ })

    # if the requested mode is the same as the current mode, don't switch
    [[ "${mode_id[*]}" == "${MODE_CUR[0]} ${MODE_CUR[1]}" ]] && return 1

    if [[ "$HAS_MODESET" == "kms" ]]; then
        # update the target resolution even though the underlying fb hasn't changed
        MODE_CUR=($(get_${HAS_MODESET}_mode_info "${mode_id[*]}"))
        # inject the environment variables to do modesetting for SDL2 applications
        command_prefix="SDL_VIDEO_KMSDRM_CRTCID=${MODE_CUR[0]} SDL_VIDEO_KMSDRM_MODEID=${MODE_CUR[1]}"
        COMMAND="$(echo "$command_prefix $COMMAND" | sed -e "s/;/; $command_prefix /g")"

        return 0
    elif [[ "$HAS_MODESET" == "x11" ]]; then
        # query the target resolution
        MODE_CUR=($(get_${HAS_MODESET}_mode_info "${mode_id[*]}"))
        # set target resolution
        $XRANDR --output "${MODE_CUR[0]}" --mode "${MODE_CUR[1]}"

        [[ "$?" -eq 0 ]] && return 0
    elif [[ "$HAS_MODESET" == "tvs" ]]; then
        if [[ "${mode_id[0]}" == "PAL" ]] || [[ "${mode_id[0]}" == "NTSC" ]]; then
            $TVSERVICE -c "${mode_id[*]}" >/dev/null
        else
            $TVSERVICE -e "${mode_id[*]}" >/dev/null
        fi

        # if we have switched mode, switch the framebuffer resolution also
        if [[ "$?" -eq 0 ]]; then
            sleep 1
            MODE_CUR=($(get_${HAS_MODESET}_mode_info))
            [[ -z "$FB_NEW" ]] && FB_NEW="${MODE_CUR[2]}x${MODE_CUR[3]}"
            return 0
        fi
    fi

    return 1
}

function restore_fb() {
    sleep 1
    switch_fb_res "${FB_ORIG[0]}x${FB_ORIG[1]}" "${FB_ORIG[2]}"
}

function config_dispmanx() {
    # if we are running under X then don't try and use dispmanx
    [[ -n "$DISPLAY" || "$XINIT" -eq 1 ]] && return
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
    local conf="/dev/shm/retroarch.cfg"
    local dim

    # only for retroarch emulators
    [[ "$EMULATOR" != lr-* ]] && return

    # make sure tmp folder exists for unpacking archives
    mkdir -p "/tmp/retroarch"

    rm -f "$conf"
    touch "$conf"
    iniConfig " = " '"' "$conf"

    if [[ -n "$HAS_MODESET" && "${MODE_CUR[5]}" -gt 0 ]]; then
        # set video_refresh_rate in our config to the same as the screen refresh
        iniSet "video_refresh_rate" "${MODE_CUR[5]}"
    fi

    # populate with target resolution & fullscreen flag if KMS is active
    if [[ "$HAS_MODESET" != "tvs" ]]; then
        iniSet "video_fullscreen" "true"
        iniSet "video_fullscreen_x" "${MODE_CUR[2]}"
        iniSet "video_fullscreen_y" "${MODE_CUR[3]}"
    # if our render resolution is "config", then we don't set anything (use the value in the retroarch.cfg)
    elif [[ "$RENDER_RES" != "config" ]]; then
        if [[ "$RENDER_RES" == "output" ]]; then
            dim=(0 0)
        else
            dim=(${RENDER_RES/x/ })
        fi
        iniSet "video_fullscreen_x" "${dim[0]}"
        iniSet "video_fullscreen_y" "${dim[1]}"
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
    if [[ "$NETPLAY" -eq 1 ]] && [[ -f "$RETRONETPLAY_CONF" ]]; then
        source "$RETRONETPLAY_CONF"
        COMMAND+=" -$__netplaymode $__netplayhostip_cfile --port $__netplayport --nick $__netplaynickname"
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
    if [[ ! -f "$EMU_SYS_CONF" ]]; then
        echo "No config found for system $SYSTEM"
        stop_joy2key
        exit 1
    fi

    # get system & rom specific emulator if set
    local emulator="$(default_emulator get emu_sys)"
    if [[ -z "$emulator" ]]; then
        echo "No default emulator found for system $SYSTEM"
        start_joy2key
        choose_emulator "emu_sys" "" "--nocancel"
        stop_joy2key
        get_sys_command "$SYSTEM" "$ROM"
        return
    fi
    EMULATOR="$emulator"

    # get default emulator for system + rom combination
    # try the old key first and convert to the new key if found
    emulator="$(default_emulator get emu_rom_old)"

    if [[ -n "$emulator" ]]; then
        default_emulator del emu_rom_old
        default_emulator set emu_rom "$emulator"
        EMULATOR="$emulator"
    else
        emulator="$(default_emulator get emu_rom)"
        [[ -n "$emulator" ]] && EMULATOR="$emulator"
    fi

    COMMAND="$(default_emulator get emu_cmd)"

    # replace tokens
    COMMAND="${COMMAND//\%ROM\%/\"$ROM\"}"
    COMMAND="${COMMAND//\%BASENAME\%/\"$ROM_BN\"}"

    # special case to get the last 2 folders for quake games for the -game parameter
    # remove everything up to /quake/
    local quake_dir="${ROM##*/quake/}"
    # remove filename
    quake_dir="${quake_dir%/*}"
    COMMAND="${COMMAND//\%QUAKEDIR\%/\"$quake_dir\"}"

    # if it starts with CON: it is a console application (so we don't redirect stdout later)
    if [[ "$COMMAND" == CON:* ]]; then
        # remove CON:
        COMMAND="${COMMAND:4}"
        CONSOLE_OUT=1
    fi

    # if it starts with XINIT: it is an X11 application (so we need to launch via xinit)
    if [[ "$COMMAND" == XINIT:* ]]; then
        # remove XINIT:
        COMMAND="${COMMAND:6}"
        XINIT=1
    fi
}

function show_launch() {
    local images=()

    if [[ "$IS_SYS" -eq 1 && "$USE_ART" -eq 1 ]]; then
        # if using art look for images in paths for es art.
        images+=(
            "$HOME/RetroPie/roms/$SYSTEM/images/${ROM_BN}-image"
            "$HOME/.emulationstation/downloaded_images/$SYSTEM/${ROM_BN}-image"
        )
    fi

    # look for custom launching images
    if [[ "$IS_SYS" -eq 1 ]]; then
        images+=(
            "$HOME/RetroPie/roms/$SYSTEM/images/${ROM_BN}-launching"
            "$CONF_ROOT/launching"
        )
    fi
    [[ "$IS_PORT" -eq 1 ]] && images+=("$CONFIGDIR/ports/launching")
    images+=("$CONFIGDIR/all/launching")

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

    if [[ -n "$image" ]]; then
        # if we are running under X use feh otherwise try and use fbi
        if [[ -n "$DISPLAY" ]]; then
            feh -F -N -Z -Y -q "$image" & &>/dev/null
            IMG_PID=$!
            sleep "$IMAGE_DELAY"
        else
            fbi -1 -t "$IMAGE_DELAY" -noverbose -a "$image" </dev/tty &>/dev/null
        fi
    elif [[ "$DISABLE_MENU" -ne 1 && "$USE_ART" -ne 1 ]]; then
        local launch_name
        if [[ -n "$ROM_BN" ]]; then
            launch_name="$ROM_BN ($EMULATOR)"
        else
            launch_name="$EMULATOR"
        fi
        DIALOGRC="$CONFIGDIR/all/runcommand-launch-dialog.cfg" dialog --infobox "\nLaunching $launch_name ...\n\nPress a button to configure\n\nErrors are logged to $LOG" 9 60
    fi
}

function check_menu() {
    local dont_launch=0
    # check for key pressed to enter configuration
    IFS= read -s -t 2 -N 1 key </dev/tty
    if [[ -n "$key" ]]; then
        [[ -n "$IMG_PID" ]] && kill -SIGINT "$IMG_PID"
        tput cnorm
        main_menu
        dont_launch=$?
        tput civis
        clear
    fi
    return $dont_launch
}

# calls script with parameters SYSTEM, EMULATOR, ROM, and commandline
function user_script() {
    local script="$CONFIGDIR/all/$1"
    if [[ -f "$script" ]]; then
        bash "$script" "$SYSTEM" "$EMULATOR" "$ROM" "$COMMAND" </dev/tty 2>>"$LOG"
    fi
}

function restore_cursor_and_exit() {
    # if we are not being run from emulationstation (get parent of parent), turn the cursor back on.
    if [[ "$(ps -o comm= -p $(ps -o ppid= -p $PPID))" != "emulationstatio" ]]; then
        tput cnorm
    fi

    exit 0
}

function launch_command() {
    local ret
    # escape $ to avoid variable expansion (eg roms containing $!)
    COMMAND="${COMMAND//\$/\\\$}"
    # launch the command
    echo -e "Parameters: $@\nExecuting: $COMMAND" >>"$LOG"
    if [[ "$CONSOLE_OUT" -eq 1 ]]; then
        # turn cursor on
        tput cnorm
        eval $COMMAND </dev/tty 2>>"$LOG"
        ret=$?
        tput civis
    else
        eval $COMMAND </dev/tty &>>"$LOG"
        ret=$?
    fi
    return $ret
}

function runcommand() {
    get_config

    if ! get_params "$@"; then
        echo "$0 MODE COMMAND [SAVENAME]"
        echo "$0 MODE _SYS_/_PORT_ SYSTEM ROM"
        exit 1
    fi

    # turn off cursor and clear screen
    tput civis
    clear

    rm -f "$LOG"
    echo -e "$SYSTEM\n$EMULATOR\n$ROM\n$COMMAND" >/dev/shm/runcommand.info
    user_script "runcommand-onstart.sh"

    set_save_vars

    load_mode_defaults

    start_joy2key
    show_launch

    if [[ "$DISABLE_MENU" -ne 1 ]]; then
        if ! check_menu; then
            stop_joy2key
            user_script "runcommand-onend.sh"
            clear
            restore_cursor_and_exit 0
        fi
    fi
    stop_joy2key

    mode_switch "$MODE_REQ_ID"

    # replace X/Y resolution and refresh (useful for KMS/modesetting)
    COMMAND="${COMMAND//\%XRES\%/${MODE_CUR[2]}}"
    COMMAND="${COMMAND//\%YRES\%/${MODE_CUR[3]}}"
    COMMAND="${COMMAND//\%REFRESH\%/${MODE_CUR[5]}}"

    [[ -n "$FB_NEW" ]] && switch_fb_res $FB_NEW

    config_dispmanx "$SAVE_EMU"

    # switch to configured cpu scaling governor
    [[ -n "$GOVERNOR" ]] && set_governor "$GOVERNOR"

    retroarch_append_config

    # build xinitrc and rewrite command if not already in X11 context
    if [[ "$XINIT" -eq 1 && "$HAS_MODESET" != "x11" ]]; then
        build_xinitrc build
    fi

    local ret
    launch_command
    ret=$?

    [[ -n "$IMG_PID" ]] && kill -SIGINT "$IMG_PID"

    clear

    # remove tmp folder for unpacked archives if it exists
    rm -rf "/tmp/retroarch"

    # restore default cpu scaling governor
    [[ -n "$GOVERNOR" ]] && restore_governor

    # if we switched mode - restore preferred mode
    mode_switch "$MODE_ORIG_ID"

    # delete temporary xinitrc launch script
    if [[ "$XINIT" -eq 1 && "$HAS_MODESET" != "x11" ]]; then
        build_xinitrc clear
    fi

    # reset/restore framebuffer res (if it was changed)
    [[ -n "$FB_NEW" ]] && restore_fb

    [[ "$EMULATOR" == lr-* ]] && retroarchIncludeToEnd "$CONF_ROOT/retroarch.cfg"

    user_script "runcommand-onend.sh"

    restore_cursor_and_exit "$ret"
}

runcommand "$@"
