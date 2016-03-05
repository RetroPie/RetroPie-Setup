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
    local mode="$2"

    # key + values
    local ini_options=(
        'video_smooth true false'
        'aspect_ratio_index _id_ 4:3 16:9 16:10 16:15 1:1 2:1 3:2 3:4 4:1 4:4 5:4 6:5 7:9 8:3 8:7 19:12 19:14 30:17 32:9 config square core custom'
        'video_shader_enable true false'
        "video_shader _file_ *.*p $rootdir/emulators/retroarch/shader"
        'input_overlay_enable true false'
        "input_overlay _file_ *.cfg $rootdir/emulators/retroarch/overlays"
    )

    local ini_descs=(
        'Smoothens picture with bilinear filtering. Should be disabled if using pixel shaders.'
        'Aspect ratio to use (default core - set aspect_ratio_auto to false to use this)'
        'Load video_shader on startup. Other shaders can still be loaded later in runtime.'
        'Video shader to use (default none)'
        'Load input overlay on startup. Other overlays can still be loaded later in runtime.'
        'Input overlay to use (default none)'
    )
    
    if [[ "$mode" == "2" ]]; then
        ini_options+=(
            'audio_driver alsa alsa_thread sdl2'
            'video_driver gl dispmanx sdl2 vg'
            'video_fullscreen_x _string_'
            'video_fullscreen_y _string_'
            'video_threaded true false'
            'video_force_aspect true false'
            'video_scale_integer true false'
            'video_aspect_ratio_auto true false'
            'video_aspect_ratio _string_'
            'video_rotation _string_'
            'custom_viewport_width _string_'
            'custom_viewport_height _string_'
            'custom_viewport_x _string_'
            'custom_viewport_y _string_'
            'fps_show true false'
            'input_overlay_opacity _string_'
            'input_overlay_scale _string_'
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

        ini_descs+=(
            'Audio driver to use (default is alsa_thread)'
            'Video driver to use (default is gl)'
            'Fullscreen resolution. Resolution of 0 uses the resolution of the desktop.'
            'Fullscreen resolution. Resolution of 0 uses the resolution of the desktop.'
            'Use threaded video driver. Using this might improve performance at possible cost of latency and more video stuttering.'
            'Forces rendering area to stay equal to content aspect ratio or as defined in video_aspect_ratio.'
            'Only scales video in integer steps. The base size depends on system-reported geometry and aspect ratio. If video_force_aspect is not set, X/Y will be integer scaled independently.'
            'If this is true and video_aspect_ratio or video_aspect_ratio_index is not set, aspect ratio is decided by libretro implementation. If this is false, 1:1 PAR will always be assumed if video_aspect_ratio or  video_aspect_ratio_index is not set.'
            'A floating point value for video aspect ratio (width / height). If this is not set, aspect ratio is assumed to be automatic. Behavior then is defined by video_aspect_ratio_auto.'
            'Forces a certain rotation of the screen. The rotation is added to rotations which the libretro core sets (see video_allow_rotate). The angle is <value> * 90 degrees counter-clockwise.'
            'Viewport resolution.'
            'Viewport resolution.'
            'Viewport position x.'
            'Viewport position y.'
            'Show current frames per second.'
            'Opacity of overlay. Float value 1.000000.'
            'Scale of overlay. Float value 1.000000.'
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
    fi

    iniFileEditor "$config"
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

function basic_configedit() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Which platform do you want to adjust" 22 76 16)
        local configs=()
        local options=()
        local config
        local dir
        local desc
        local i=0
        while read config; do
            configs+=("$config")
            dir=${config%/*}
            dir=${dir//$configdir\//}
            if [[ "$dir" == "all" ]]; then
                desc="Configure default options for all libretro emulators"
            else
                desc="Configure additional options for $dir"
            fi
            options+=("$i" "$desc")
            ((i++))
        done < <(find "$configdir" -type f -regex ".*/retroarch.cfg" | sort)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            common_configedit "${configs[choice]}"
        else
            break
        fi
    done
}

function advanced_configedit() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Configure Libretro options"
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
                        common_configedit "$configdir/$file" 2
                        ;;
                    2)
                        file=$(choose_config_configedit "$configdir" ".*/retroarch.*")
                        editFile "$configdir/$file" 2
                        ;;
                    3)
                        file=$(choose_config_configedit "$configdir" ".*/all/.*")
                        editFile "$configdir/$file" 2
                        ;;
                    4)
                        file=$(choose_config_configedit "$configdir" ".*" ".*retroarch.*")
                        editFile "$configdir/$file" 2
                        ;;
                    5)
                        file=$(choose_config_configedit "$configdir" ".*")
                        editFile "$configdir/$file" 2
                        ;;
                esac
            done
        else
            break
        fi
    done
}

function configure_configedit() {
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local options=(
            1 "Configure basic libretro emulator options"
            2 "Advanced Configuration"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        local file="-"
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    basic_configedit
                    ;;
                2)
                    advanced_configedit
                    ;;
            esac
        else
            break
        fi
    done
}
