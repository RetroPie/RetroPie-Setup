#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dbar4gun"
rp_module_desc="dbar4gun is a Linux userspace driver for the wiimote with DolphinBar support."
rp_module_help="https://github.com/lowlevel-1989/dbar4gun"
rp_module_licence="MIT https://raw.githubusercontent.com/lowlevel-1989/dbar4gun/master/LICENSE"
rp_module_repo="git https://github.com/lowlevel-1989/dbar4gun master"
rp_module_section="driver"

function depends_dbar4gun() {
    getDepends python3 python3-dev python3-setuptools python3-virtualenv python3-pygame
}

function sources_dbar4gun() {
    gitPullOrClone
}

function install_dbar4gun() {
    virtualenv -p python3 "$md_inst"
    source "$md_inst/bin/activate"
    pip3 install .
    deactivate
    md_ret_require="$md_inst/bin/dbar4gun"
}

function configure_dbar4gun() {
    if [[ "$md_mode" == "remove" ]]; then
        return
    fi

    touch "$configdir/all/dbar4gun.cfg"
    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
}

function enable_dbar4gun() {
    local config="/etc/systemd/system/dbar4gun.service"

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    local dbar4gun_params="--width $db_width --height $db_height"
    dbar4gun_params="$dbar4gun_params --calibration $db_calibration"
    dbar4gun_params="$dbar4gun_params --setup $db_setup"
    dbar4gun_params="$dbar4gun_params --port $db_port"
    dbar4gun_params="$dbar4gun_params --smoothing-level $db_smoothing_level"

    if [[ "$db_disable_tilt_correction" -eq 1 ]]; then
        dbar4gun_params="$dbar4gun_params --disable-tilt-correction"
    fi

    disable_dbar4gun
    cat > "$config" << _EOF_
[Unit]
Description=dbar4gun

[Service]
Type=simple
ExecStart=$md_inst/bin/dbar4gun start $dbar4gun_params

[Install]
WantedBy=multi-user.target
_EOF_
    systemctl daemon-reload

    systemctl enable dbar4gun --now
    printMsgs "dialog" "dbar4gun enabled."
}

function disable_dbar4gun() {
    systemctl disable dbar4gun --now
}

function remove_dbar4gun() {
    disable_dbar4gun
    rm -rf "/etc/systemd/system/dbar4gun.service"
    systemctl daemon-reload
}

function _loadconfig_dbar4gun() {
    echo "$(loadModuleConfig \
        'db_width=1920' \
        'db_height=1080' \
        'db_disable_tilt_correction=0' \
        'db_setup=1' \
        'db_port=35460' \
        'db_calibration=2' \
        'db_smoothing_level=3'
    )"
}

function _menu_start_dbar4gun() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "dbar4gun service" 22 86 16)

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    while true; do

        local options=(
            1 "width: $db_width"
            2 "height: $db_height"
            3 "smoothing level: $db_smoothing_level"
            4 "debug port: $db_port"
        )

        if [[ "$db_disable_tilt_correction" -eq 1 ]]; then
            options+=(5 "enable tilt correction")
        else
            options+=(5 "disable tilt correction")
        fi

        options+=(6 "dbar4gun start")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    local cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the width" 10 60 "$db_width")
                    db_width=$("${cmd_in[@]}" 2>&1 >/dev/tty)
                    iniSet "db_width" "$db_width"
                    ;;
                2)
                    local cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the height" 10 60 "$db_height")
                    db_height=$("${cmd_in[@]}" 2>&1 >/dev/tty)
                    iniSet "db_height" "$db_height"
                    ;;
                3)
                    local cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the smoothing level" 10 60 "$db_smoothing_level")
                    db_smoothing_level=$("${cmd_in[@]}" 2>&1 >/dev/tty)
                    iniSet "db_smoothing_level" "$db_smoothing_level"
                    ;;
                4)
                    local cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the debug port" 10 60 "$db_port")
                    db_port=$("${cmd_in[@]}" 2>&1 >/dev/tty)
                    iniSet "db_port" "$db_port"
                    ;;
                5)
                    db_disable_tilt_correction="$((db_disable_tilt_correction ^ 1))"
                    iniSet "db_disable_tilt_correction" "$db_disable_tilt_correction"
                    ;;
                6)
                    enable_dbar4gun
                    break
                    ;;
            esac
        else
            break
        fi
    done

}

function _menu_ir_setup() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "IR Setup" 22 86 16)

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    local options=(
        1 "Standard"
    )

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    iniSet "db_setup" "1"
                    _menu_calibration_mode
                    break
                    ;;
            esac
        else
            break
        fi
    done
}

function _menu_calibration_mode() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Calibration Mode" 22 86 16)

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    local options=(
        1 "TopLeft, TopRight, BottomCenter"
        2 "Center,  TopLeft"
        3 "disabled"
    )

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    iniSet "db_calibration" "2"
                    _menu_start_dbar4gun
                    break
                    ;;
                2)
                    iniSet "db_calibration" "1"
                    _menu_start_dbar4gun
                    break
                    ;;
                3)
                    iniSet "db_calibration" "0"
                    _menu_start_dbar4gun
                    break
                    ;;
            esac
        else
            break
        fi
    done
}

function _menu_set_resolution() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose Resolution" 22 86 16)

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    local options=(
        1 " 1080p"
        2 "  720p"
        3 "manual"
    )

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    iniSet "db_width" "1920"
                    iniSet "db_height" "1080"
                    _menu_ir_setup
                    break
                    ;;
                2)
                    iniSet "db_width" "1280"
                    iniSet "db_height" "720"
                    _menu_ir_setup
                    break
                    ;;
                3)
                    _menu_ir_setup
                    break
                    ;;
            esac
        else
            break
        fi
    done
}

function gui_dbar4gun() {
    local title=$($md_inst/bin/dbar4gun version)
    local cmd=(dialog --backtitle "$__backtitle" --menu "$title" 22 86 16)
    local options=(
        1 "Enable dbar4gun"
        2 "Disable dbar4gun"
        3 "Debug"
    )

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    _menu_set_resolution
                    ;;
                2)
                    disable_dbar4gun
                    ;;
                3)
                    $md_inst/bin/dbar4gun gui --width 640 --height 480 --port $db_port
                    ;;
            esac
        else
            break
        fi
    done
}
