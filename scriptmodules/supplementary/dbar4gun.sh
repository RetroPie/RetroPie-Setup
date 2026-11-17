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
    getDepends python3 python3-dev python3-setuptools python3-venv python3-pygame
}

function sources_dbar4gun() {
    gitPullOrClone
}

function install_dbar4gun() {
    # --system-site-packages: the calibrator uses python3-pygame from apt
    python3 -m venv --system-site-packages "$md_inst"
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
    eval $(_loadconfig_dbar4gun)

    _retropiemenu_entry_dbar4gun install
    if [[ "$db_calibrator_entry" -eq 1 ]]; then
        _calibrator_entry_dbar4gun install
    fi
}

function _params_dbar4gun() {
    local dbar4gun_params="--width $db_width --height $db_height"
    dbar4gun_params="$dbar4gun_params --calibration $db_calibration"
    dbar4gun_params="$dbar4gun_params --port $db_port"
    dbar4gun_params="$dbar4gun_params --smoothing-level $db_smoothing_level"
    dbar4gun_params="$dbar4gun_params --area $db_area"
    dbar4gun_params="$dbar4gun_params --useful-zone $db_useful_zone"
    dbar4gun_params="$dbar4gun_params --config-dir $configdir/all/dbar4gun"

    if [[ "$db_disable_tilt_correction" -eq 1 ]]; then
        dbar4gun_params="$dbar4gun_params --disable-tilt-correction"
    fi

    if [[ "$db_distance_compensation" -eq 0 ]]; then
        dbar4gun_params="$dbar4gun_params --no-distance-compensation"
    fi

    # Bluetooth: by default dbar4gun grabs the Wiimote/Nunchuk gamepads of the
    # kernel so their buttons do not arrive twice
    if [[ "$db_input_grab" -eq 0 ]]; then
        dbar4gun_params="$dbar4gun_params --no-input-grab"
    fi

    echo "$dbar4gun_params"
}

function _calibrator_cmd_dbar4gun() {
    local cmd="$md_inst/bin/dbar4gun gui --port $db_port"
    if [[ "$db_calibrator_size" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        cmd+=" --width ${BASH_REMATCH[1]} --height ${BASH_REMATCH[2]}"
    fi
    if [[ "$db_calibrator_lang" == "es" ]]; then
        cmd+=" --lang es"
    fi
    echo "$cmd"
}

function _retropiemenu_entry_dbar4gun() {
    local rpdir="$datadir/retropiemenu"
    if [[ "$1" == "install" ]]; then
        mkUserDir "$rpdir"
        touch "$rpdir/dbar4gun.rp"
        chown "$__user":"$__group" "$rpdir/dbar4gun.rp"
        local function
        for function in $(compgen -A function _add_rom_); do
            "$function" "retropie" "RetroPie" "dbar4gun.rp" "Light Gun (dbar4gun)" "Light gun service for the Wii Remote: settings and calibrator." ""
        done
    else
        rm -f "$rpdir/dbar4gun.rp"
    fi
}

function _calibrator_entry_dbar4gun() {
    setConfigRoot "ports"
    if [[ "$1" == "install" ]]; then
        addPort "$md_id" "dbar4gun" "dbar4gun calibrator" "$(_calibrator_cmd_dbar4gun)"
    else
        delEmulator "$md_id" "dbar4gun"
        rm -f "$romdir/ports/dbar4gun calibrator.sh"
        if [[ "$(find "$romdir/ports" -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l)" -eq 0 ]]; then
            delSystem "ports"
        fi
    fi
    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
}

function _hooks_dbar4gun() {
    if [[ "$1" == "install" ]]; then
        "$md_inst/bin/dbar4gun" hooks install --configs-dir "$configdir/all" --bin "$md_inst/bin/dbar4gun"
    else
        [[ -x "$md_inst/bin/dbar4gun" ]] && "$md_inst/bin/dbar4gun" hooks uninstall --configs-dir "$configdir/all"
    fi
}

function _enable_service_dbar4gun() {
    local config="/etc/systemd/system/dbar4gun.service"

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    local dbar4gun_params="$(_params_dbar4gun)"

    if [[ "$db_runcommand_hooks" -eq 1 ]]; then
        _hooks_dbar4gun install
    else
        _hooks_dbar4gun remove
    fi

    _disable_service_dbar4gun
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
}

function _disable_service_dbar4gun() {
    systemctl disable dbar4gun --now
}

function remove_dbar4gun() {
    _disable_service_dbar4gun
    _retropiemenu_entry_dbar4gun remove
    _calibrator_entry_dbar4gun remove
    _hooks_dbar4gun remove
    rm -rf "/etc/systemd/system/dbar4gun.service"
    systemctl daemon-reload
}

function _set_area_dbar4gun() {
    local error
    if error=$("$md_inst/bin/dbar4gun" check --area "$1" 2>&1); then
        db_area="$1"
        iniSet "db_area" "$db_area"
        return 0
    fi
    printMsgs "dialog" "Invalid area profile '$1': $error"
    return 1
}

function _set_useful_zone_dbar4gun() {
    local error
    if error=$("$md_inst/bin/dbar4gun" check --area full --useful-zone "$1" 2>&1); then
        db_useful_zone="$1"
        iniSet "db_useful_zone" "$db_useful_zone"
        return 0
    fi
    printMsgs "dialog" "Invalid useful zone '$1': $error"
    return 1
}

function _set_calibrator_size_dbar4gun() {
    if [[ "$1" == "native" || "$1" =~ ^[0-9]+x[0-9]+$ ]]; then
        db_calibrator_size="$1"
        iniSet "db_calibrator_size" "$db_calibrator_size"
        return 0
    fi
    printMsgs "dialog" "Invalid calibrator resolution '$1': native or WIDTHxHEIGHT"
    return 1
}

function _loadconfig_dbar4gun() {
    echo "$(loadModuleConfig \
        'db_width=1920' \
        'db_height=1080' \
        'db_disable_tilt_correction=0' \
        'db_port=35460' \
        'db_calibration=3' \
        'db_smoothing_level=3' \
        'db_area=full' \
        'db_useful_zone=0.85' \
        'db_distance_compensation=1' \
        'db_input_grab=1' \
        'db_calibrator_entry=0' \
        'db_calibrator_size=native' \
        'db_calibrator_lang=en' \
        'db_runcommand_hooks=1'
    )"
}

function _menu_calibration_mode_dbar4gun() {
    local cmd=(dialog --backtitle "$__backtitle" --default-item "$db_calibration" --menu "Calibration Mode" 22 86 16)
    local options=(
        3 "Top Left, Top Right, Bottom Right, Bottom Left"
        2 "Top Left, Top Right, Bottom Center"
        1 "Center, Top Left"
        0 "Disabled"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        db_calibration="$choice"
        iniSet "db_calibration" "$db_calibration"
    fi
}

function gui_dbar4gun() {
    local title=$($md_inst/bin/dbar4gun version)
    local cmd=(dialog --backtitle "$__backtitle" --menu "$title" 22 86 16)
    local modes=("Disabled" "Center, Top Left" "Top Left, Top Right, Bottom Center" "4 Corners")
    local options
    local choice
    local cmd_in
    local value
    local enabled

    iniConfig " = " '"' "$configdir/all/dbar4gun.cfg"
    eval $(_loadconfig_dbar4gun)

    while true; do
        enabled=0
        systemctl -q is-enabled dbar4gun 2>/dev/null && enabled=1

        options=()
        if [[ "$enabled" -eq 1 ]]; then
            options+=(1 "Disable dbar4gun")
        else
            options+=(1 "Enable dbar4gun")
        fi
        options+=(
            2 "Calibrate Now"
            3 "Width: $db_width"
            4 "Height: $db_height"
            5 "Calibration Mode: ${modes[$db_calibration]}"
            6 "Smoothing Level: $db_smoothing_level"
        )

        if [[ "$db_disable_tilt_correction" -eq 1 ]]; then
            options+=(7 "Enable Tilt Correction")
        else
            options+=(7 "Disable Tilt Correction")
        fi

        if [[ "$db_distance_compensation" -eq 1 ]]; then
            options+=(8 "Disable Distance Compensation")
        else
            options+=(8 "Enable Distance Compensation")
        fi

        options+=(9 "Default Area Profile: $db_area")
        options+=(10 "Useful Zone: $db_useful_zone")

        if [[ "$db_runcommand_hooks" -eq 1 ]]; then
            options+=(11 "Disable Area Profiles per Game (runcommand)")
        else
            options+=(11 "Enable Area Profiles per Game (runcommand)")
        fi

        if [[ "$db_input_grab" -eq 1 ]]; then
            options+=(12 "Bluetooth: Allow the Double Input (Wiimote also as Gamepad)")
        else
            options+=(12 "Bluetooth: Block the Double Input (Wiimote only as Light Gun)")
        fi

        options+=(13 "Calibrator Resolution: $db_calibrator_size")
        options+=(14 "Calibrator Language: $db_calibrator_lang")

        if [[ "$db_calibrator_entry" -eq 1 ]]; then
            options+=(15 "Remove Calibrator from Ports")
        else
            options+=(15 "Add Calibrator to Ports")
        fi

        options+=(16 "Debug Port: $db_port")

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1)
                if [[ "$enabled" -eq 1 ]]; then
                    _disable_service_dbar4gun
                    printMsgs "dialog" "dbar4gun disabled."
                else
                    _enable_service_dbar4gun
                    printMsgs "dialog" "dbar4gun enabled."
                fi
                continue
                ;;
            2)
                if ! systemctl -q is-active dbar4gun; then
                    printMsgs "dialog" "dbar4gun is not running: enable it first."
                    continue
                fi
                joy2keyStop
                su "$__user" -c "XDG_RUNTIME_DIR=/run/user/$(id -u "$__user") $(_calibrator_cmd_dbar4gun)"
                joy2keyStart
                continue
                ;;
            3)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the width" 10 60 "$db_width")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && db_width="$value" && iniSet "db_width" "$db_width"
                ;;
            4)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the height" 10 60 "$db_height")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && db_height="$value" && iniSet "db_height" "$db_height"
                ;;
            5)
                _menu_calibration_mode_dbar4gun
                ;;
            6)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the smoothing level" 10 60 "$db_smoothing_level")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && db_smoothing_level="$value" && iniSet "db_smoothing_level" "$db_smoothing_level"
                ;;
            7)
                db_disable_tilt_correction="$((db_disable_tilt_correction ^ 1))"
                iniSet "db_disable_tilt_correction" "$db_disable_tilt_correction"
                ;;
            8)
                db_distance_compensation="$((db_distance_compensation ^ 1))"
                iniSet "db_distance_compensation" "$db_distance_compensation"
                ;;
            9)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Default area profile: full, 4:3 or custom:x0,y0,w,h (per game profiles: $configdir/all/dbar4gun/profiles.cfg)" 12 70 "$db_area")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && _set_area_dbar4gun "$value"
                ;;
            10)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Useful zone: fraction of the screen height with targets (0.3 - 1.0)" 10 70 "$db_useful_zone")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && _set_useful_zone_dbar4gun "$value"
                ;;
            11)
                db_runcommand_hooks="$((db_runcommand_hooks ^ 1))"
                iniSet "db_runcommand_hooks" "$db_runcommand_hooks"
                ;;
            12)
                db_input_grab="$((db_input_grab ^ 1))"
                iniSet "db_input_grab" "$db_input_grab"
                ;;
            13)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Calibrator resolution: native, or WIDTHxHEIGHT (e.g. 1280x720) if it is slow on the TV" 10 70 "$db_calibrator_size")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && _set_calibrator_size_dbar4gun "$value"
                [[ "$db_calibrator_entry" -eq 1 ]] && _calibrator_entry_dbar4gun install
                continue
                ;;
            14)
                if [[ "$db_calibrator_lang" == "es" ]]; then
                    db_calibrator_lang="en"
                else
                    db_calibrator_lang="es"
                fi
                iniSet "db_calibrator_lang" "$db_calibrator_lang"
                [[ "$db_calibrator_entry" -eq 1 ]] && _calibrator_entry_dbar4gun install
                continue
                ;;
            15)
                db_calibrator_entry="$((db_calibrator_entry ^ 1))"
                iniSet "db_calibrator_entry" "$db_calibrator_entry"
                if [[ "$db_calibrator_entry" -eq 1 ]]; then
                    _calibrator_entry_dbar4gun install
                else
                    _calibrator_entry_dbar4gun remove
                fi
                continue
                ;;
            16)
                cmd_in=(dialog --backtitle "$__backtitle" --inputbox "Please enter the debug port" 10 60 "$db_port")
                value=$("${cmd_in[@]}" 2>&1 >/dev/tty) && db_port="$value" && iniSet "db_port" "$db_port"
                [[ "$db_calibrator_entry" -eq 1 ]] && _calibrator_entry_dbar4gun install
                ;;
        esac
        # a setting changed while the service is enabled is applied at once
        [[ "$enabled" -eq 1 ]] && _enable_service_dbar4gun
    done
}
