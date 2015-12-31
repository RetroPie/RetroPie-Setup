#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="configedit"
rp_module_desc="Edit RetroPie/RetroArch configurations"
rp_module_menus="3+"
rp_module_flags="nobin"

function common_configedit() {
    local config="$1"

    # create a list of all present shader presets
    local shader
    local video_shader="video_shader "
    for shader in /opt/retropie/emulators/retroarch/shader/*.glslp; do
        # Do not add presets with whitespace
        if [[ "$shader" != *" "* ]]; then
            video_shader+="$shader "
        fi
    done

    # key + values
    local common=(
        'video_driver gl dispmanx sdl2 vg'
        'video_fullscreen_x _string_'
        'video_fullscreen_y _string_'
        'video_threaded true false'
        'video_smooth true false'
        'video_force_aspect true false'
        'video_scale_integer true false'
        'video_aspect_ratio _string_'
        'video_aspect_ratio_auto true false'
        'video_shader_enable true false'
        "$video_shader"
        'video_rotation _string_'
        'fps_show true false'
        'input_joypad_driver udev sdl2 linuxraw'
        'input_player1_analog_dpad_mode 0 1 2'
        'input_player2_analog_dpad_mode 0 1 2'
        'input_player3_analog_dpad_mode 0 1 2'
        'input_player4_analog_dpad_mode 0 1 2'
        'input_player5_analog_dpad_mode 0 1 2'
        'input_player6_analog_dpad_mode 0 1 2'
        'input_player7_analog_dpad_mode 0 1 2'
        'input_player8_analog_dpad_mode 0 1 2'
    )
    
    local descs=(
        'Video driver to use (default is gl)'
        'Fullscreen resolution. Resolution of 0 uses the resolution of the desktop.'
        'Fullscreen resolution. Resolution of 0 uses the resolution of the desktop.'
        'Use threaded video driver. Using this might improve performance at possible cost of latency and more video stuttering.'
        'Smoothens picture with bilinear filtering. Should be disabled if using pixel shaders.'
        'Forces rendering area to stay equal to content aspect ratio or as defined in video_aspect_ratio.'
        'Only scales video in integer steps. The base size depends on system-reported geometry and aspect ratio. If video_force_aspect is not set, X/Y will be integer scaled independently.'
        'Load video_shader on startup. Other shaders can still be loaded later in runtime.'
        'Video shader to use (default none)'
        'A floating point value for video aspect ratio (width / height). If this is not set, aspect ratio is assumed to be automatic. Behavior then is defined by video_aspect_ratio_auto.'
        'If this is true and video_aspect_ratio is not set, aspect ratio is decided by libretro implementation. If this is false, 1:1 PAR will always be assumed if video_aspect_ratio is not set.'
        'Forces a certain rotation of the screen. The rotation is added to rotations which the libretro core sets (see video_allow_rotate). The angle is <value> * 90 degrees counter-clockwise.'
        'Show current frames per second.'
        'Input joypad driver to use (default is udev)'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
        'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    )

    [[ ! -f "$config" ]] && return

    iniConfig " = " "" "$config"
    while true; do
        local options=()
        local params=()
        local values=()
        local keys=()
        local i=0
        # generate menu from options
        for option in "${common[@]}"; do
            option=($option)
            keys+=("${option[0]}")
            params+=("${option[*]:1}")
            iniGet "${option[0]}"
            [[ -z "$ini_value" ]] && ini_value="unset"
            values+=("$ini_value")
            options+=("$i" "${option[0]} ($ini_value)" "${descs[i]}")
            ((i++))
        done
        local key
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$key" --item-help --help-button --menu "Please choose the setting to modify in $config" 22 76 16)
        key=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${key[@]:0:4}" == "HELP" ]]; then
            printMsgs "dialog" "${key[@]:5}"
            continue
        fi
        if [[ -n "$key" ]]; then
            options=()
            local default
            params=(${params[$key]})
            i=0
            for option in "${params[@]}"; do
                # handle case where the value type is _string_
                if [[ "$option" == "_string_" ]]; then
                    options+=("E" "Edit (Currently ${values[key]})")
                    continue
                fi
                [[ "${values[key]}" == "$option" ]] && default="$i"
                options+=("$i" "$option")
                ((i++))
            done
            options+=("U" "unset")

            # display values
            cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Please choose the value for " 12 76 06)
            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

            # if it is a _string_ type we will open an inputbox dialog to get a manual value
            if [[ -z "$choice" ]]; then
                continue
            elif [[ "$choice" == "E" ]]; then
                [[ "${values[key]}" == "unset" ]] && values[key]=""
                cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the value for ${keys[key]}" 10 60 "${values[key]}")
                value=$("${cmd[@]}" 2>&1 >/dev/tty)
            elif [[ "$choice" == "U" ]]; then
                value="$default"
            else
                # get the actual value from the options array
                local index=$((choice*2+1))
                value="${options[index]}"
            fi

            # save the #include line and remove it, so we can add our ini values and re-add the include line(s) at the end
            local include=$(grep "^#include" "$config")
            sed -i "/^#include/d" "$config"

            if [[ "$choice" == "U" ]]; then
                iniUnset "${keys[key]}" "$value"
            else
                iniSet "${keys[key]}" "$value"
            fi

            # re-add the include line(s)
            if [[ -n "$include" ]]; then
                echo "" >>"$config"
                echo "$include" >>"$config"
            fi
        else
            break
        fi
    done
}

function choose_config_configedit() {
    local path="$1"
    local include="$2"
    local exclude="$3"
    [[ -z "$wildcard" ]] && wildcard="*"
    local cmd=(dialog --backtitle "$__backtitle" --menu "Which configuration would you like to edit" 22 76 16)
    local configs=()
    local options=()
    local config
    local i=0
    while read config; do
        config=${config//$path\//}
        configs+=("$config")
        options+=("$i" "$config")
        ((i++))
    done < <(find "$path" -type f -regex "$include" ! -regex "$exclude" | sort)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        echo "${configs[choice]}"
    fi
}

function configure_configedit() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Change common RetroArch options"
            2 "Manually edit RetroArch configurations"
            3 "Manually edit global configs"
            4 "Manually edit non RetroArch configurations"
            5 "Manually edit all configurations"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        local file="-"
        if [[ -n "$choice" ]]; then
            while [[ -n "$file" ]]; do
                case $choice in
                    1)
                        file=$(choose_config_configedit "$configdir" ".*/retroarch.cfg")
                        common_configedit "$configdir/$file"
                        ;;
                    2)
                        file=$(choose_config_configedit "$configdir" ".*/retroarch.*")
                        editFile "$configdir/$file"
                        ;;
                    3)
                        file=$(choose_config_configedit "$configdir" ".*/all/.*")
                        editFile "$configdir/$file"
                        ;;
                    4)
                        file=$(choose_config_configedit "$configdir" ".*" ".*retroarch.*")
                        editFile "$configdir/$file"
                        ;;
                    5)
                        file=$(choose_config_configedit "$configdir" ".*")
                        editFile "$configdir/$file"
                        ;;
                esac
            done
        else
            break
        fi
    done
}
