#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="steamcontroller"
rp_module_desc="User-mode driver for Steam Controller"
rp_module_help="Steam Controller Driver from https://github.com/C0rn3j/sc-controller"
rp_module_licence="GPL2 https://raw.githubusercontent.com/C0rn3j/sc-controller/python3/LICENSE"
rp_module_repo="git https://github.com/C0rn3j/sc-controller.git v0.5.4"
rp_module_section="driver"

function _update_hook_steamcontroller() {
    # remove the start command from the previous scriptmodule version
    if rp_isInstalled "$md_id"; then
        sed -i "/bin\/sc-.*.py/d" /etc/rc.local
    fi
}
function depends_steamcontroller() {
    getDepends python3-virtualenv python3-dev python3-setuptools
}

function sources_steamcontroller() {
    gitPullOrClone
}

function install_steamcontroller() {
    # build the driver in a virtualenv created in $md_inst
    virtualenv -p python3 "$md_inst"
    source "$md_inst/bin/activate"
    pip3 install libusb1 evdev ioctl_opt
    pip3 install "sccontroller @ file://$md_build"
    deactivate

    # copy the default controller profiles
    md_ret_files=("default_profiles")
}

function enable_steamcontroller() {
    local profile="$1"
    [[ -z "$profile" ]] && profile="XBox Controller"

    disable_steamcontroller
    cat > /etc/systemd/system/sc-controller.service << _EOF_
[Unit]
Description=Userspace Steamcontroller driver

[Service]
ExecStart="$md_inst/bin/scc-daemon" "$md_inst/default_profiles/$profile.sccprofile" debug
ExecStop="$md_inst/bin/scc-daemon" stop

[Install]
WantedBy=multi-user.target
_EOF_
    systemctl daemon-reload
    systemctl -q enable sc-controller.service
    systemctl start sc-controller.service
    printMsgs "dialog" "Steamcontroller enabled and started with profile:\n\n$profile"
}

function disable_steamcontroller() {
    # remove start commands from /etc/rc.local
    [[ -f "/etc/rc.local" ]] && sed -i "/bin\/scc-daemon.*start/d" /etc/rc.local
    if systemctl -q is-enabled sc-controller.service 2>/dev/null; then
        systemctl stop sc-controller.service
        systemctl -q disable sc-controller.service
    fi
}

function remove_steamcontroller() {
    disable_steamcontroller
    rm -f /etc/udev/rules.d/99-steam-controller.rules
    if [[ -f "/etc/systemd/system/sc-controller.service" ]]; then
        rm -f "/etc/systemd/system/sc-controller.service"
        systemctl daemon-reload
    fi
}

function configure_steamcontroller() {
    cat >/etc/udev/rules.d/99-steam-controller.rules <<_EOF_
# Steam controller keyboard/mouse mode
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", GROUP="input", MODE="0660"

# Valve HID devices over bluetooth hidraw
KERNEL=="hidraw*", KERNELS=="*28de:*", MODE="0660", GROUP="input", TAG+="uaccess"

# Steam controller gamepad mode
KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
_EOF_
}

function gui_steamcontroller() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Enable Steamcontroller (Xbox controller mode)"
        2 "Enable Steamcontroller (Desktop mouse/keyboard mode)"
        3 "Disable Steamcontroller"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    enable_steamcontroller "XBox Controller"
                    ;;
                2)
                    enable_steamcontroller "Desktop"
                    ;;
                3)
                    disable_steamcontroller
                    printMsgs "dialog" "Steamcontroller service has been disabled"
                    ;;
            esac
        else
            break
        fi
    done
}
