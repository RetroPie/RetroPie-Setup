#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xboxdrv"
rp_module_desc="Xbox / Xbox 360 gamepad driver"
rp_module_licence="GPL3 https://raw.githubusercontent.com/RetroPie/xboxdrv/stable/COPYING"
rp_module_repo="git https://github.com/RetroPie/xboxdrv.git retropie-stable"
rp_module_section="driver"

function def_controllers_xboxdrv() {
    echo "2"
}

function def_deadzone_xboxdrv() {
    echo "4000"
}

function depends_xboxdrv() {
    getDepends libboost-dev libusb-1.0-0-dev libudev-dev libx11-dev scons pkg-config python3 x11proto-core-dev libdbus-glib-1-dev
}

function sources_xboxdrv() {
    gitPullOrClone
}

function build_xboxdrv() {
    python3 /usr/bin/scons
}

function install_xboxdrv() {
    make install PREFIX="$md_inst"
}

function enable_xboxdrv() {
    local controllers="$1"
    local deadzone="$2"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrv)"
    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrv)"

    local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --dbus disabled --detach-kernel-driver"

    local i
    for (( i=0; i<$controllers; i++)); do
        [[ $i -gt 0 ]] && config+=" --next-controller"
        config+=" --id $i --led $((i+2)) --deadzone $deadzone --silent --trigger-as-button"
    done

    # remove any previously start-up commands in /etc/rc.local
    [[ -f /etc/rc.local ]] && sed -i "/xboxdrv/d" /etc/rc.local

    cat > /etc/systemd/system/xboxdrv.service << _EOF_
[Unit]
Description=Userspace Xbox gamepad driver and input remapper
ConditionPathExists=$md_inst/bin/xboxdrv

[Service]
Type=forking
PIDFile=/run/xboxdrv.pid
ExecStart=$config --pid-file /run/xboxdrv.pid

[Install]
WantedBy=multi-user.target
_EOF_
    systemctl daemon-reload
    systemctl -q start xboxdrv
    systemctl enable xboxdrv
    printMsgs "dialog" "xboxdrv has been enabled and started"
}

function disable_xboxdrv() {
    [[ -f /etc/rc.local ]] && sed -i "/xboxdrv/d" /etc/rc.local
    systemctl -q is-enabled xboxdrv 2>/dev/null && systemctl disable xboxdrv
    systemctl -q is-active xboxdrv 2>/dev/null && systemctl stop xboxdrv

    printMsgs "dialog" "xboxdrv auto-start has been disabled"
}

function controllers_xboxdrv() {
    local controllers="$1"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrv)"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$controllers" --menu "Select the number of controllers to enable" 22 86 16)
    local options=(
        1 "1 controller"
        2 "2 controllers"
        3 "3 controllers"
        4 "4 controllers"
    )

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        controllers="$choice"
    fi

    echo "$controllers"
}

function deadzone_xboxdrv() {
    local deadzone="$1"

    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrv)"

    local zones=()
    local options=()
    local i
    local label
    local default
    for i in {0..12}; do
        zones[i]=$((i*500))
        [[ ${zones[i]} -eq $deadzone ]] && default=$i
        label="0-${zones[i]}"
        [[ "$i" -eq 0 ]] && label="No Deadzone"
        options+=($i "$label")
    done

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Select range of your analog stick deadzone" 22 86 16)

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        deadzone="${zones[$choice]}"
    fi

    echo "$deadzone"
}

function remove_xboxdrv()
{
    disable_xboxdrv

    if [[ -f "/etc/systemd/system/xboxdrv.service" ]]; then
        rm -f "/etc/systemd/system/xboxdrv.service"
        systemctl daemon-reload
    fi
}

function gui_xboxdrv() {
    if [[ ! -f "$md_inst/bin/xboxdrv" ]]; then
        if [[ $__has_binaries -eq 1 ]]; then
            rp_callModule "$md_id" depends
            rp_callModule "$md_id" install_bin
        else
            rp_callModule "$md_id"
        fi
    fi

    local controllers="$(def_controllers_xboxdrv)"
    local deadzone="$(def_deadzone_xboxdrv)"
    local is_enabled="disabled"
    local operation="Enable"
    systemctl -q is-enabled xboxdrv && is_enabled="enabled" && operation="Disable"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do
        local options=(
            1 "$operation xboxdrv (currently: $is_enabled)"
            2 "Set number of controllers to enable (currently $controllers)"
            3 "Set analog stick deadzone (currently $deadzone)"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then

            case "$choice" in
                1)
                    if [[ $is_enabled == "disabled" ]]; then
                        enable_xboxdrv "$controllers" "$deadzone"
                    else
                        disable_xboxdrv
                    fi
                    ;;
                2)
                    controllers=$(controllers_xboxdrv $controllers)
                    ;;
                3)
                    deadzone=$(deadzone_xboxdrv $deadzone)
                    ;;
            esac
        else
            break
        fi
    done
}
