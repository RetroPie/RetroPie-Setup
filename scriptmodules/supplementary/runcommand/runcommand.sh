#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
# Editor's note: You may notice "\c \%" escape sequences, these are needed
# to avoid the initial % char to be swallowed by doxygen.

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
## Additionally it is possible to pass in the current screen resolution
## (selectable in the runcommand menu) to the emulator to be launched. The
## respective variables are \c \%XRES% and \c \%YRES% which will be replaced
## with the specific values as the placeholders \c \%ROM% and \c \%BASENAME%
## (see below). For example it is possible to set \c
## --displaysize=\%XRESx\%YRES% in emulators.cfg` if an emulator has a command
## line switch to set the resolution.
##
## If `_SYS_` or `_PORT_` is provided as the second parameter for the
## `runcommand.sh` script, the commandline will be extracted from
## `/opt/retropie/configs/SYSTEM/emulators.cfg` with \c \%ROM%, \c \%BASENAME%
## being replaced with the `ROM` parameter. This is the default mode used when
## launching in RetroPie so the user can switch emulator used as well as other
## options from the runcommand GUI.
##
## If `SAVE_NAME` is included, that is used for loading and saving of video output
## modes as well as rendering backend settings for the current `COMMAND`. If omitted,
## the binary name is used as a key for the loading and saving. The savename is
## also displayed in the video output menu (detailed below), so for our purposes
## we send the emulator module id, which is somewhat descriptive yet short.
##
## On launch this script waits for two seconds for a key or joystick press. If
## pressed the GUI is shown, where a user can set video modes, default emulators
## and other options (depending what is being launched).

ROOTDIR="/opt/retropie"
CONFIGDIR="$ROOTDIR/configs"
LOG="/dev/shm/runcommand.log"

RUNCOMMAND_CONF="$CONFIGDIR/all/runcommand.cfg"
VIDEO_CONF="$CONFIGDIR/all/videomodes.cfg"
EMU_CONF="$CONFIGDIR/all/emulators.cfg"
BACKENDS_CONF="$CONFIGDIR/all/backends.cfg"
RETRONETPLAY_CONF="$CONFIGDIR/all/retronetplay.cfg"
JOY2KEY="$ROOTDIR/admin/joy2key/joy2key"

# modesetting tools
TVSERVICE="/opt/vc/bin/tvservice"
KMSTOOL="$ROOTDIR/supplementary/kmsxx/kmsprint-rp"
XRANDR="xrandr"

source "$ROOTDIR/lib/inifuncs.sh"

# disable the `patsub_replacement` shell option, it breaks the string substitution when replacement contains '&'
if shopt -s patsub_replacement 2>/dev/null; then
    shopt -u patsub_replacement
fi

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
    elif [[ -c /dev/dri/card0 ]] && KMS_BUFFER="$($KMSTOOL 2>/dev/null)"; then
        HAS_MODESET="kms"
    elif [[ -f "$TVSERVICE" ]]; then
        HAS_MODESET="tvs"
    fi
}

function start_joy2key() {
    # check if joystick support is enabled and joy2key is available
    [[ "$DISABLE_JOYSTICK" -eq 1 || ! -f "$JOY2KEY" ]] && return

    "$JOY2KEY" start 2>/dev/null && return 0
}

function stop_joy2key() {
    # if joy2key is installed, stop it
    [[ -f "$JOY2KEY" ]] && "$JOY2KEY" stop
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
        # if we have an emulator name (such as module_id) we use that for storing/loading parameters for video mode / backend
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
    default_mode="$(echo "$KMS_BUFFER" | grep -Em1 "^Mode: [0-9]+ crtc")"
    crtc="$(echo "$default_mode" | cut -d' ' -f  4)"
    crtc_encoder="$(echo "$KMS_BUFFER" | grep "Encoder map:" | awk -v crtc="$crtc" '$5 == crtc { print $3 }')"

    # add default mode as fallback in case real mode cannot be mapped
    MODE[def-def]="$(echo "$default_mode" | cut -d' ' -f5-)"

    # parse only the video modes connected to the current active crtc
    while read -r mode_str mode_id con encoder_id info; do
           # we only need 2nd column (mode index) and the 5+ columns (resolution info)
           # populate resolution info into arrays (using mapped crtc encoder value)
           MODE_ID+=($crtc-$mode_id)
           MODE[$crtc-$mode_id]="$info"

           # if string matches default mode, add a special mapped entry
           [[ "$default_mode" =~ "$info" ]] && MODE[map-map]="$crtc $mode_id"
    done < <(echo "$KMS_BUFFER" | grep -E "^Mode: [0-9]+ connector $crtc_encoder")
}

function get_all_x11_modes()
{
    declare -Ag MODE
    local id
    local line
    while read -r id; do
        # populate CONNECTOR:0xID into an array
        MODE_ID+=($id) # output:id as in (hdmi:0x44)

        read -r line
        # array is x/y resolution @ vertical refresh rate ( details )
        MODE[$id]="$line"
    done < <( $XRANDR --verbose | awk '
        # defines the type of line
        # true is the "header" (output and id)
        # false is the "description" (Mode: and everything that begins with a space)
        { type = /^[^ \t]+/ }

        # Exit after the first output
        type && output {exit} # New header and output set means new output

        # many outputs can be connected, but only the ones with the id are in use.
        # output must be connected and have an (id)
        type && / connected/ && /\(0x[0-9a-f]+\)/ {
            output=$1; next
        }

        # parse mode and lines
        # If we are in a "description", and output is set (output being what we want)
        # And if $2 is an id, we are in a video mode description line
        !type && output && $2 ~ /^\(0x[0-9a-f]+\)$/ {
            # Print CRTC identifier (CONNECTOR:0xID)
            print output ":" substr($2,2,length($2)-2) # id

            # get rid of what we printed
            $1="";$2=""
            sub(/^[ \t]+/,"") # trim spaces

            # save rest of the line
            info=$0

            # Save width from the 2nd line of the video mode
            getline; width=$3

            # Save height & vrefresh from the 3rd line of video mode
            getline; height=$3; vrefresh=$NF

            # Print video mode details
            print width "x" height " @ " vrefresh " (" info ")"
        }
    ')
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

    # split resolution (1st column)
    status=(${MODE[${mode_id[0]}-${mode_id[1]}]/x/ })

    # get crtc id
    mode_info[0]="${mode_id[0]}"

    # get mode id
    mode_info[1]="${mode_id[1]}"

    # get mode resolution
    mode_info[2]="${status[0]}"
    # yres may have an ending 'i'(nterlace) flag
    mode_info[3]="${status[1]/i/}"

    # get aspect ratio (5th column)
    mode_info[4]="${status[5]}"

    # get refresh rate (4th column, remove surrounding brackets)
    mode_info[5]="${status[4]//[()]/}"

    echo "${mode_info[@]}"
}

function get_x11_mode_info() {
    local mode_id=(${1/:/ })
    local mode_info=()
    local status

    if [[ -z "$mode_id" ]]; then
        # determine current output
        mode_id[0]="$($XRANDR --verbose | awk '/ connected.*\(0x[a-f0-9]{1,}\)/ { print $1;exit }')"
        # determine current mode id & strip brackets
        mode_id[1]="$($XRANDR --verbose | awk '/ connected.*\(0x[a-f0-9]{1,}\)/ {print;exit}' | grep -o "(0x[a-f0-9]\{1,\})")"
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
    mode_info[5]="$(LC_NUMERIC=C printf '%.0f\n' ${status[3]::-2})"

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
    local default

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
                ES "Select default emulator for $SYSTEM ($emu_sys)"
                ER "Select emulator for ROM ($emu_rom)"
            )
        fi

        if [[ -n "$HAS_MODESET" ]]; then
            local vid_emu="$(default_mode get vid_emu)"
            local vid_rom="$(default_mode get vid_rom)"
            options+=(
                VE "Select video mode for $EMULATOR ($vid_emu)"
                VR "Select video mode for $EMULATOR + ROM ($vid_rom)"
            )
        fi

        if [[ "$EMULATOR" == lr-* ]]; then
            if [[ "$HAS_MODESET" == "tvs" ]]; then
                options+=(R "Select RetroArch render res for $EMULATOR ($RENDER_RES)")
            fi
            options+=(C "Edit custom RetroArch config for this ROM")
        elif [[ "$HAS_MODESET" == "tvs" ]]; then
            local fb_emu="$(default_mode get fb_emu)"
            local fb_rom="$(default_mode get fb_rom)"
            options+=(
                FE "Select framebuffer res for $EMULATOR ($fb_emu)"
                FR "Select framebuffer res for $EMULATOR + ROM ($fb_rom)"
            )
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

        cmd=(dialog --nocancel --default-item "$default" --menu "System: $SYSTEM\nEmulator: $EMULATOR\nVideo Mode: $temp_mode\nROM: $ROM_BN"  22 76 16 )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"

        case "$choice" in
            ES)
                choose_emulator "emu_sys" "$emu_sys"
                ;;
            ER)
                choose_emulator "emu_rom" "$emu_rom"
                ;;
            VE)
                choose_mode "vid_emu" "$vid_emu"
                ;;
            VR)
                choose_mode "vid_rom" "$vid_rom"
                ;;
            R)
                choose_render_res "render" "$RENDER_RES"
                ;;
            C)
                touch "$ROM.cfg"
                cmd=(dialog --editbox "$ROM.cfg" 22 76)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                [[ -n "$choice" ]] && echo "$choice" >"$ROM.cfg"
                [[ ! -s "$ROM.cfg" ]] && rm "$ROM.cfg"
                ;;
            FE)
                choose_mode "fb_emu" "$fb_emu"
                ;;
            FR)
                choose_mode "fb_rom" "$fb_rom"
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
                VERBOSE=1
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

    local key
    local options=()
    local mode_desc=""

    options=("X" "Clear / Remove")
    if [[ "$mode" == vid_* ]]; then
        mode_desc="video mode for "
        for key in "${MODE_ID[@]}"; do
            options+=("$key" "${MODE[$key]}")
        done
    elif [[ "$mode" == fb_* ]]; then
        mode_desc="framebuffer resolution for "
        for key in $(get_resolutions); do
            options+=("$key" "$key")
        done
    fi

    if [[ "$mode" == *_emu ]]; then
        mode_desc+="$EMULATOR"
    else
        mode_desc+="$EMULATOR + ROM ($ROM_BN)"
    fi

    local menu_title="Choose $mode_desc\nCurrently: "
    if [[ -z "$default" ]]; then
        menu_title+="(not set)"
    else
        menu_title+="$default"
    fi

    local cmd=(dialog --default-item "$default" --menu "$menu_title"  22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    if [[ "$choice" == "X" ]]; then
        default_mode del "$mode"
    else
        default_mode set "$mode" "$choice"
    fi
    load_mode_defaults
}

function choose_emulator() {
    local mode="$1"
    local default="$2"
    local cancel="$3"

    local mode_desc="default emulator for "
    if [[ "$mode" == "emu_sys" ]]; then
        mode_desc+="$SYSTEM"
    else
        mode_desc+="ROM ($ROM_BN)"
    fi

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
    if [[ "${#options[@]}" -eq 0 ]]; then
        dialog --msgbox "No emulator options found for $SYSTEM - Do you have a valid $EMU_SYS_CONF ?" 20 60 >/dev/tty
        stop_joy2key
        exit 1
    fi
    [[ "$mode" != "emu_sys" ]] && options=("X" "Clear / Remove" "${options[@]}")

    local menu_title="Choose $mode_desc\nCurrently: "
    if [[ -z "$default" ]]; then
        menu_title+="(not set)"
    else
        menu_title+="$default"
    fi

    local cmd=(dialog $cancel --default-item "$default_id" --menu "$menu_title"  22 76 16 )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    if [[ "$choice" == "X" ]]; then
        default_emulator del "$mode"
    else
        default_emulator set "$mode" "${apps[$choice]}"
    fi
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

            if [[ "$XINIT_WM" -gt 0 ]]; then
                local params=()
                [[ "$XINIT_WM" -eq 1 ]] && params+=(-use_cursor no)
                [[ "$XINIT_WM" -eq 2 ]] && params+=(-use_cursor yes)
                cat >>"$xinitrc" <<_EOF_
matchbox-window-manager ${params[@]} &
sleep 0.5
xset -dpms s off s noblank
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

            # if no TTY env var is set, try and get it - eg if launching a ports script or runcommand manually
            if [[ -z "$TTY" ]]; then
                TTY=$(tty)
                TTY=${TTY:8:1}
            fi

            # if we managed to get the current tty then try and use it
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

        # check the mode tuple against the list of current available CRCTID/MODEID values
        if [[ -n ${MODE["${MODE_CUR[0]}-${MODE_CUR[1]}"]} ]]; then
            # inject the environment variables to do modesetting for SDL2 applications
            command_prefix="SDL_VIDEO_KMSDRM_CRTCID=${MODE_CUR[0]} SDL_VIDEO_KMSDRM_MODEID=${MODE_CUR[1]}"
        fi
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
            clear
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

function config_backend() {
    # if we are running under X then don't try and use a different backend
    [[ -n "$DISPLAY" || "$XINIT" -eq 1 ]] && return
    local name="$1"
    # if we have a backends.conf file and with an entry for the current emulator name,
    # change the library path to load dispmanx sdl first
    if [[ -f "$BACKENDS_CONF" ]]; then
        iniConfig " = " '"' "$BACKENDS_CONF"
        iniGet "$name"
        case "$ini_value" in
            1|dispmanx)
                if [[ "$HAS_MODESET" == "kms" ]]; then
                    COMMAND="SDL_DISPMANX_WIDTH=${MODE_CUR[2]} SDL_DISPMANX_HEIGHT=${MODE_CUR[3]} $COMMAND"
                fi
                COMMAND="SDL1_VIDEODRIVER=dispmanx $COMMAND"
                ;;
            sdl12-compat)
                COMMAND="LD_PRELOAD=\"$ROOTDIR/supplementary/sdl12-compat/libSDL-1.2.so.0\" $COMMAND"
                ;;
            x11)
                XINIT=1
                XINIT_WM=1
                ;;
            x11-c)
                XINIT=1
                XINIT_WM=2
                ;;
        esac
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

    # strip any suffix decimals appearing in refresh rate, just for comparison
    if [[ -n "$HAS_MODESET" && "${MODE_CUR[5]%.*}" -gt 0 ]]; then
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

    # set `libretro_directory` to the core parent folder
    local core_dir=$(echo "$COMMAND" | grep -Eo "$ROOTDIR/libretrocores/.*libretro\.so" | head -n 1)
    core_dir=$(dirname "$core_dir")
    [[ -n "$core_dir" ]] && iniSet "libretro_directory" "$core_dir"

    # if verbose logging is on, set core logging to INFO
    [[ "$VERBOSE" -eq 1 ]] && iniSet "libretro_log_level" "1"

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

    # check if COMMAND starts with a launch OPTION:
    if [[ "$COMMAND" =~ ^([A-Z\-]+?):(.*)$ ]]; then
        # extract the command
        COMMAND="${BASH_REMATCH[2]}"

        case "${BASH_REMATCH[1]}" in
            # if it starts with CON: it is a console application (so we don't redirect stdout later)
            CON)
                CONSOLE_OUT=1
                ;;
            # if it starts with XINIT it is an X11 application (so we need to launch via xinit)
            XINIT*)
                XINIT=1
                ;;&
            # if it starts with XINIT-WM or XINIT-WMC (with cursor) it is an X11 application needing a window manager
            XINIT-WM)
                XINIT_WM=1
                ;;
            XINIT-WMC)
                XINIT_WM=2
                ;;
        esac
    fi

}

function show_launch() {
    local images=()

    if [[ "$IS_SYS" -eq 1 && "$USE_ART" -eq 1 ]]; then
        # if using art look for images in paths for es art.
        images+=(
            "$HOME/RetroPie/roms/$SYSTEM/images/${ROM_BN}-image"
            "$HOME/.emulationstation/downloaded_images/$SYSTEM/${ROM_BN}-image"
            "$HOME/.emulationstation/downloaded_media/$SYSTEM/screenshots/${ROM_BN}"
            "$HOME/RetroPie/roms/$SYSTEM/media/screenshots/${ROM_BN}"
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
        eval "$COMMAND" </dev/tty 2>>"$LOG"
        ret=$?
        tput civis
    else
        eval "$COMMAND" </dev/tty &>>"$LOG"
        ret=$?
    fi
    return $ret
}

function log_info() {
    echo -e "$SYSTEM\n$EMULATOR\n$ROM\n$COMMAND" >/dev/shm/runcommand.info
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
    log_info
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

    # resave info after menu and resolution replacements so runcommand.info is up to date
    log_info

    [[ -n "$FB_NEW" ]] && switch_fb_res $FB_NEW

    config_backend "$SAVE_EMU"

    # switch to configured cpu scaling governor
    [[ -n "$GOVERNOR" ]] && set_governor "$GOVERNOR"

    retroarch_append_config

    # build xinitrc and rewrite command if not already in X11 context
    if [[ "$XINIT" -eq 1 && "$HAS_MODESET" != "x11" ]]; then
        build_xinitrc build
    fi

    user_script "runcommand-onlaunch.sh"

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
